import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'dart:convert';  // Ensure this is imported
import '/models/tally.dart';  // Ensure this points to the correct location of the Tally class

enum AuthStatus { uninitialized, authenticated, authenticating, unauthenticated, authenticateError }

class SocialAuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  AuthStatus _status = AuthStatus.uninitialized;
  User? _currentUser;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;

  SocialAuthProvider() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  Future<void> handleGoogleSignIn() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      _currentUser = userCredential.user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.authenticateError;
      debugPrint('Google Sign-In Error: $e');
    }

    notifyListeners();
  }

  Future<void> handleSignOut() async {
    try {
      await _firebaseAuth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      debugPrint('Sign-Out Error: $e');
      _status = AuthStatus.authenticateError;
    }

    notifyListeners();
  }

  // Backup data to Google Drive
  Future<void> backupToDrive(BuildContext context, List<Tally> tallies) async {
    final driveApi = await getDriveApi();  // Change _getDriveApi to getDriveApi
    if (driveApi == null) return;

    final jsonData = tallies.map((tally) => tally.toJson()).where((element) => element != null).toList();
    final driveFile = drive.File()
      ..name = 'task_up_backup.json'
      ..parents = ['appDataFolder'];

    final media = drive.Media(
      Stream.fromIterable([utf8.encode(jsonEncode(jsonData))]),
      jsonData.length,
    );

    await driveApi.files.create(driveFile, uploadMedia: media);
  }

  // Restore data from Google Drive
  Future<List<Tally>?> restoreFromDrive(BuildContext context) async {
    final driveApi = await getDriveApi();  // Change _getDriveApi to getDriveApi
    if (driveApi == null) return null;

    final fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name='task_up_backup.json'",
    );

    if (fileList.files!.isEmpty) {
      debugPrint('No backup found');
      return null;
    }

    final fileId = fileList.files!.first.id!;
    final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

    final jsonData = await media.stream.transform(utf8.decoder).join();
    final List<dynamic> jsonList = jsonDecode(jsonData);

    return jsonList.map((json) => Tally.fromJson(json)).toList();
  }

  // Get Google Drive API instance
  Future<drive.DriveApi?> getDriveApi() async {  // Made this method public
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    return drive.DriveApi(authenticateClient);
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
