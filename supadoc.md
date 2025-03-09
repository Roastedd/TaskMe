# TaskMe Supabase Documentation

Below is an in-depth documentation context tailored for the TaskMe Flutter app. This guide compiles all the essential steps and components for using Supabase with Flutter. It's designed to be comprehensive, modular, and easy to follow, so you can efficiently integrate user management, authentication, real-time updates, and profile photo uploads.

## Project Information

**Project Name:** TaskMe  
**Organization:** ezteaed@gmail.com's Org  
**Plan:** Free  
**Project URL:** https://hkjagszkbwvvwzzvlvlp.supabase.co  
**API Key (anon/public):** eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhramFnc3prYnd2dnd6enZsdmxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk4NTQ0MTcsImV4cCI6MjAyNTQzMDQxN30.RK_cEgXyxCNr4mvKgXfpFBUkOjNX4FagYRe7-VY5DYE

## 1. Project Setup

### 1.1 Dependencies and Assets

Add these to your `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.4
  flutter_dotenv: ^5.0.2
  logging: ^1.1.0
  url_launcher: ^6.1.8
  image_picker: ^1.0.5

# Add this assets section
flutter:
  uses-material-design: true
  
  assets:
    - .env
    - assets/
    - assets/images/
    - assets/icon/
    - assets/google_logo.png
```

### 1.2 Project Structure

Create the following directory structure:
```
TaskMe/
├── assets/
│   ├── images/
│   │   └── logo.png      # Add your app logo here (required)
│   ├── icon/
│   │   └── icon_fore.png # Add your app icon here
│   └── google_logo.png   # Add Google sign-in logo
├── lib/
└── ...
```

To set up the required assets:
1. Create the `assets` directory in your project root:
   ```bash
   mkdir -p assets/images assets/icon
   ```
2. Add your app logo:
   - Place your app logo at `assets/images/logo.png`
   - Recommended size: 120x120 pixels
   - If you don't have a logo yet, use a placeholder:
     ```bash
     # Download a placeholder logo (replace this with your actual logo later)
     curl https://via.placeholder.com/120 > assets/images/logo.png
     ```

3. Add your app icon:
   - Place your app icon at `assets/icon/icon_fore.png`
   - This is used for launcher icons
   - Required for the splash screen

### 1.3 Environment Configuration

Create a `config.dart` file:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class Config {
  static final _logger = Logger('Config');
  
  // Supabase configuration
  static String get supabaseUrl => 
    dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
  
  static String get supabaseAnonKey =>
    dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';
  
  // Deep linking configuration
  static const String scheme = 'io.supabase.taskme';
  static const String host = 'login-callback';
  
  static String get redirectUrl {
    if (kIsWeb) {
      return '$supabaseUrl/auth/v1/callback';
    }
    return '$scheme://$host/';
  }
  
  // Google OAuth Client IDs
  static const String iosGoogleClientId = '75977774800-bcu9perem41q2l40qj81oh48j9g0eeeo.apps.googleusercontent.com';
  static const String webGoogleClientId = '75977774800-i9f076j5esfh8lo4ke1idfi486sft5nv.apps.googleusercontent.com';
  
  static String get googleClientId {
    if (Platform.isIOS) {
      return iosGoogleClientId;
    }
    return webGoogleClientId;
  }
  
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
      _logger.info('Environment variables loaded successfully');
    } catch (e) {
      _logger.warning('Failed to load .env file. Using default values.', e);
    }
  }
}
```

### 1.4 Initialize Supabase

In your `main.dart`:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load configuration
  await Config.load();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
    debug: true,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  
  runApp(const MyApp());
}
```

## 2. Authentication Implementation

### 2.1 Email/Password Authentication

```dart
class AuthService {
  final _logger = Logger('AuthService');
  
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      _logger.severe('Sign in failed', e);
      return false;
    }
  }
  
  Future<bool> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      _logger.severe('Sign up failed', e);
      return false;
    }
  }
}
```

### 2.2 Google Authentication

```dart
Future<bool> signInWithGoogle() async {
  try {
    final redirectUrl = Config.redirectUrl;
    
    final response = await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
      queryParams: {
        'prompt': 'select_account',
        'access_type': 'offline',
      },
      authScreenLaunchMode: LaunchMode.inAppWebView,
    );
    
    if (!response) return false;
    
    // Wait for auth state to change
    bool authenticated = false;
    int attempts = 0;
    const maxAttempts = 30;
    
    while (!authenticated && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 500));
      final session = supabase.auth.currentSession;
      if (session != null) {
        authenticated = true;
        return true;
      }
      attempts++;
    }
    
    return false;
  } catch (e) {
    _logger.severe('Google sign in failed', e);
    return false;
  }
}
```

### 2.3 Magic Link Authentication

```dart
Future<void> sendMagicLink(String email) async {
  try {
    await supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: Config.redirectUrl,
    );
  } catch (e) {
    _logger.severe('Magic link sign in failed', e);
    rethrow;
  }
}
```

## 3. Deep Linking Setup

### 3.1 iOS Configuration
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.taskme</string>
      <string>com.googleusercontent.apps.75977774800-bcu9perem41q2l40qj81oh48j9g0eeeo</string>
    </array>
    <key>CFBundleURLName</key>
    <string>io.supabase.taskme</string>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
  </dict>
</array>
```

### 3.2 Android Configuration
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="io.supabase.taskme" android:host="login-callback" />
</intent-filter>
```

### 3.3 Supabase Dashboard Configuration
1. Go to Authentication > URL Configuration
2. Add Redirect URLs:
   ```
   io.supabase.taskme://login-callback/
   https://hkjagszkbwvvwzzvlvlp.supabase.co/auth/v1/callback
   ```

## 4. Database Schema

```sql
create table todos (
  id bigint generated by default,
  task text,
  status status default 'Not Started',
  user_id uuid references auth.users not null,
  inserted_at timestamp with time zone,
  updated_at timestamp with time zone,
);
```

## 5. User Management

### 5.1 User Provider
```dart
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _logger = Logger('UserProvider');
  
  User? _currentUser;
  bool _isLoading = false;
  Exception? _lastError;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  Exception? get lastError => _lastError;
  
  UserProvider() {
    _initializeUser();
    _listenToAuthChanges();
  }
  
  void _initializeUser() {
    _currentUser = Supabase.instance.client.auth.currentUser;
  }
  
  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }
}
```

### 5.2 Session Management
```dart
class AuthService {
  Stream<AuthState> onAuthStateChange() {
    return _supabase.auth.onAuthStateChange;
  }
  
  Future<void> refreshSession() async {
    final currentSession = _supabase.auth.currentSession;
    if (currentSession != null && currentSession.isExpired) {
      await _supabase.auth.refreshSession();
    }
  }
}
```

## 6. Best Practices and Security

1. **Environment Variables**
   - Use `.env` file for sensitive data
   - Never commit API keys to version control
   - Use `flutter_dotenv` for configuration

2. **Error Handling**
   - Implement proper error handling for all auth operations
   - Use logging for debugging
   - Show user-friendly error messages

3. **Session Management**
   - Implement session refresh logic
   - Monitor auth state changes
   - Handle expired tokens gracefully

4. **Security**
   - Use Row Level Security (RLS) policies
   - Validate user sessions
   - Never expose service_role key
   - Use PKCE auth flow for mobile

## 7. Troubleshooting

1. **Asset Loading Issues**
   - If you see `Error: unable to find directory entry in pubspec.yaml`:
     1. Make sure the assets directories exist:
        ```bash
        mkdir -p assets/images assets/icon
        ```
     2. Verify pubspec.yaml has correct assets:
        ```yaml
        flutter:
          assets:
            - .env
            - assets/
            - assets/images/
            - assets/icon/
            - assets/google_logo.png
        ```
     3. Run `flutter clean` and `flutter pub get`

   - If you see `Unable to load asset: "assets/images/logo.png"`:
     1. Ensure the logo file exists at `assets/images/logo.png`
     2. Temporarily modify splash_screen.dart to use an icon:
        ```dart
        Icon(
          Icons.check_circle_outline,
          size: 120,
          color: Colors.blue,
        )
        ```
     3. Add proper image assets later

2. **Authentication Issues**
   - Check redirect URLs in Supabase dashboard
   - Verify Google OAuth client IDs
   - Ensure deep linking is properly configured
   - Use debug logs to track auth flow

3. **Deep Linking Problems**
   - Verify URL schemes in Info.plist and AndroidManifest.xml
   - Check redirect URL configuration in Supabase
   - Test deep links with appropriate tools

4. **Session Handling**
   - Implement proper session refresh
   - Handle token expiration
   - Monitor auth state changes

5. **Common Fixes**
   - Clear app data/cache
   - Perform a clean build
   - Check Supabase dashboard logs
   - Verify environment variables

## 8. Useful Resources

- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/introduction)
- [Flutter Quick Start Guide](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Authentication Guide](https://supabase.com/docs/guides/auth)
- [Database Guide](https://supabase.com/docs/guides/database)
- [Storage Guide](https://supabase.com/docs/guides/storage)