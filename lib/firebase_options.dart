// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHkgDkW78agKSBdYdpfqs7dptfjIVsxd4',
    appId: '1:242105657962:android:61829b1a1a8cef16aff813',
    messagingSenderId: '242105657962',
    projectId: 'taskme-d8882',
    storageBucket: 'taskme-d8882.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDw-lqgJOPgTf5GEWz2k3xDhHRtr40rV3E',
    appId: '1:242105657962:ios:015a9933247b08a9aff813',
    messagingSenderId: '242105657962',
    projectId: 'taskme-d8882',
    storageBucket: 'taskme-d8882.appspot.com',
    iosBundleId: 'com.example.taskme',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyATxTPkhV-4GDz3jQvEYD6_VlWe7N_n20c',
    appId: '1:242105657962:web:f298119e3256bd80aff813',
    messagingSenderId: '242105657962',
    projectId: 'taskme-d8882',
    authDomain: 'taskme-d8882.firebaseapp.com',
    storageBucket: 'taskme-d8882.appspot.com',
    measurementId: 'G-78B5NBFNQD',
  );
}
