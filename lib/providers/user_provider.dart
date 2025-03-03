import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_client.dart';
import 'package:flutter/material.dart';
import '/models/level.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';
import 'dart:io' show Platform;

class AppUser {
  int xp;
  int level;

  AppUser(this.xp, this.level) {
    // Ensure level is never less than 1
    if (level < 1) level = 1;
  }
}

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _logger = Logger('UserProvider');
  User? _supabaseUser;
  bool _isLoading = false;
  final AppUser _appUser = AppUser(0, 1);

  User? get supabaseUser => _supabaseUser;
  AppUser get appUser => _appUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initUser();
  }

  void _initUser() {
    _supabaseUser = supabase.auth.currentUser;
    supabase.auth.onAuthStateChange.listen((data) {
      _logger.info('Auth state changed: ${data.event}');
      _supabaseUser = data.session?.user;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      _supabaseUser = response.user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _supabaseUser = response.user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _logger.info('Starting Google sign-in process');
      
      // Get the OAuth response from the auth service
      final oauthResponse = await _authService.signInWithGoogle();
      
      if (!oauthResponse.isSuccess) {
        _logger.severe('Failed to initiate Google sign-in: ${oauthResponse.error}');
        throw 'Failed to initiate Google sign-in: ${oauthResponse.error ?? "Unknown error"}';
      }
      
      _logger.info('Google sign-in initiated successfully');
      
      // On iOS and Android, the URL will be automatically opened by Supabase
      // For other platforms, we might need to manually launch the URL
      if (!kIsWeb && !Platform.isIOS && !Platform.isAndroid) {
        _logger.info('Manually launching URL: ${oauthResponse.url}');
        final uri = Uri.parse(oauthResponse.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _logger.severe('Could not launch URL: ${oauthResponse.url}');
          throw 'Could not launch ${oauthResponse.url}';
        }
      }
      
      // The actual user will be set via the auth state change listener in _initUser
      // when the OAuth flow completes successfully
      _logger.info('Waiting for auth state change from OAuth flow');
      
    } catch (e) {
      _logger.severe('Google sign in failed', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    // Reset app user state to initial values
    _appUser.xp = 0;
    _appUser.level = 1;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      if (email.isEmpty) {
        throw 'Email cannot be empty';
      }
      
      await _authService.resetPassword(email);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Level get currentLevel {
    // Ensure level is at least 1 before indexing
    final safeLevel = _appUser.level.clamp(1, levels.length);
    return levels[safeLevel - 1];
  }

  void addXp(int xp) {
    if (xp < 0) return; // Prevent negative XP
    
    _appUser.xp += xp;
    
    // Check for level up
    final nextLevel = levels.firstWhere(
      (level) => level.level == _appUser.level + 1,
      orElse: () => levels.last,
    );
    
    if (_appUser.xp >= nextLevel.xpNeeded && _appUser.level < levels.length) {
      _appUser.level++;
    }
    
    notifyListeners();
  }

  bool canAddTask(int currentTasksCount) => currentTasksCount < currentLevel.getMaxTasks;

  List<int> get availableColors => currentLevel.getAvailableColors;
}
