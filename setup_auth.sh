#!/bin/bash

# Navigate to project root
cd "$(dirname "$0")"

echo "Setting up authentication for TaskMe..."

# Check if Flutter is in PATH
if ! command -v flutter &> /dev/null; then
    echo "Flutter command not found. Please make sure Flutter is installed and in your PATH."
    echo "You might need to run: export PATH=\"\$PATH:\$HOME/flutter/bin\""
    exit 1
fi

echo "Installing dependencies..."
flutter pub get

echo "Cleaning build artifacts..."
flutter clean

echo "Configuring Supabase authentication..."

# Create a backup of the current auth_service.dart file
cp lib/services/auth_service.dart lib/services/auth_service.dart.bak

# Update the auth_service.dart file with the fixed implementation
cat > lib/services/auth_service.dart << 'EOL'
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show LaunchMode;
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  final _logger = Logger('AuthService');

  AuthService() {
    _logger.info('AuthService initialized');
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Attempting to sign up with email: $email');
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: !kIsWeb && Platform.isIOS 
          ? 'io.supabase.taskme://login-callback' 
          : null,
      );
      
      if (response.user == null) {
        _logger.warning('Sign up failed: No user data received');
        throw 'Sign up failed: No user data received';
      }
      
      _logger.info('Sign up successful for user: ${response.user!.email}');
      return response;
    } catch (e) {
      _logger.severe('Sign up failed', e);
      throw 'Sign up failed: ${e.toString()}';
    }
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Attempting to sign in with email: $email');
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        _logger.warning('Sign in failed: Invalid credentials');
        throw 'Sign in failed: Invalid credentials';
      }
      
      _logger.info('Sign in successful for user: ${response.user!.email}');
      return response;
    } catch (e) {
      _logger.severe('Sign in failed', e);
      throw 'Sign in failed: ${e.toString()}';
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _logger.info('Attempting to sign in with Google');
      final redirectUrl = !kIsWeb && Platform.isIOS 
          ? 'io.supabase.taskme://login-callback' 
          : null;

      _logger.info('Using redirect URL: $redirectUrl');
      
      // Use signInWithOAuth and handle the response correctly
      final res = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        queryParams: {'prompt': 'select_account'},
      );
      
      _logger.info('Google sign in response received: ${res.toString()}');
      
      // The correct way to check if the OAuth flow was initiated successfully
      return res;
    } catch (e) {
      _logger.severe('Google sign in failed', e);
      throw 'Google sign in failed: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    try {
      _logger.info('Attempting to sign out');
      final session = supabase.auth.currentSession;
      if (session == null) {
        _logger.warning('No active session found');
        throw 'No active session found';
      }
      
      await supabase.auth.signOut();
      _logger.info('Sign out successful');
    } catch (e) {
      _logger.severe('Sign out failed', e);
      throw 'Sign out failed: ${e.toString()}';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _logger.info('Attempting to reset password for email: $email');
      if (email.isEmpty) {
        _logger.warning('Email cannot be empty');
        throw 'Email cannot be empty';
      }

      final redirectUrl = !kIsWeb && Platform.isIOS
          ? 'io.supabase.taskme://reset-callback'
          : null;
          
      _logger.info('Using reset password redirect URL: $redirectUrl');
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
      _logger.info('Password reset email sent successfully');
    } catch (e) {
      _logger.severe('Password reset failed', e);
      throw 'Password reset failed: ${e.toString()}';
    }
  }

  // Get the current user's session
  Session? getCurrentSession() {
    final session = supabase.auth.currentSession;
    _logger.info('Current session: ${session?.user.email ?? 'No session'}');
    return session;
  }

  // Get the current user
  User? getCurrentUser() {
    final user = supabase.auth.currentUser;
    _logger.info('Current user: ${user?.email ?? 'No user'}');
    return user;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    final isAuth = supabase.auth.currentSession != null;
    _logger.info('Is authenticated: $isAuth');
    return isAuth;
  }

  // Listen to auth state changes
  Stream<AuthState> onAuthStateChange() {
    _logger.info('Setting up auth state change listener');
    return supabase.auth.onAuthStateChange.map((event) {
      _logger.info('Auth state changed: ${event.event}');
      return event;
    });
  }
}
EOL

echo "Setup complete! Now you can run the app with:"
echo "flutter run"

echo "Make sure to configure Google OAuth in your Supabase project:"
echo "1. Go to your Supabase dashboard: https://app.supabase.io"
echo "2. Navigate to Authentication > Providers"
echo "3. Enable Google provider"
echo "4. Add the redirect URL: io.supabase.taskme://login-callback"
echo "5. Configure your Google OAuth credentials in the Google Cloud Console" 