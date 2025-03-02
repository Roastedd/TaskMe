import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show LaunchMode;
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart'; // Import config to access the Supabase URL

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
      
      // Use the actual Supabase URL from config instead of a placeholder
      final redirectUrl = !kIsWeb && Platform.isIOS 
          ? 'io.supabase.taskme://login-callback' 
          : null;
          
      _logger.info('Using redirect URL for signup: $redirectUrl');
      
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectUrl,
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

  Future<OAuthResponse> signInWithGoogle() async {
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
      
      _logger.info('Google sign in initiated: ${res.url}');
      
      if (!res.isSuccess) {
        _logger.warning('Failed to initiate Google sign-in');
        throw 'Failed to initiate Google sign-in';
      }
      
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