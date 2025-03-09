import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_client.dart';
import 'package:logging/logging.dart';
import '../config.dart'; // Import config to access the Supabase URL
import 'dart:async';

/// Service for handling authentication with Supabase
class AuthService {
  final _logger = Logger('AuthService');
  
  // Cache for current user to avoid frequent API calls
  User? _cachedUser;
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  
  AuthService._internal() {
    _logger.info('AuthService initialized');
    _loadCachedUser();
  }
  
  /// Load cached user data from shared preferences
  Future<void> _loadCachedUser() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        _cachedUser = currentUser;
        _logger.info('Loaded cached user: ${currentUser.email}');
      }
    } catch (e) {
      _logger.warning('Failed to load cached user', e);
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Attempting to sign up with email: $email');
      
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: Config.redirectUrl,
      );
      
      if (response.user == null) {
        _logger.warning('Sign up failed: No user data received');
        throw 'Sign up failed: No user data received';
      }
      
      _cachedUser = response.user;
      _logger.info('Sign up successful for user: ${response.user!.email}');
      return response;
    } catch (e) {
      _logger.severe('Sign up failed', e);
      throw 'Sign up failed: ${e.toString()}';
    }
  }

  /// Sign in with email and password
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

      // Check if email is confirmed - using the correct property
      if (response.user!.emailConfirmedAt == null) {
        _logger.warning('Email not confirmed');
        
        // Resend confirmation email
        await supabase.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: Config.redirectUrl,
        );
        
        throw 'Email not confirmed. A new confirmation email has been sent.';
      }
      
      _cachedUser = response.user;
      _logger.info('Sign in successful for user: ${response.user!.email}');
      return response;
    } catch (e) {
      _logger.severe('Sign in failed', e);
      throw 'Sign in failed: ${e.toString()}';
    }
  }

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    try {
      _logger.info('Attempting to sign in with Google');
      
      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Config.redirectUrl,
        queryParams: {'prompt': 'select_account'},
      );
      
      _logger.info('Google sign in initiated: ${response.toString()}');
      
      // Clear cached user to force refresh on next access
      if (response) {
        _cachedUser = null;
      }
      
      return response;
    } catch (e) {
      _logger.severe('Google sign in failed', e);
      throw 'Google sign in failed: ${e.toString()}';
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      _logger.info('Attempting to sign out');
      await supabase.auth.signOut();
      _logger.info('Sign out successful');
    } catch (e) {
      _logger.severe('Sign out failed', e);
      throw 'Sign out failed: ${e.toString()}';
    }
  }

  /// Reset password for the given email
  Future<void> resetPassword(String email) async {
    try {
      _logger.info('Attempting to reset password for email: $email');
      if (email.isEmpty) {
        _logger.warning('Email cannot be empty');
        throw 'Email cannot be empty';
      }

      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: Config.redirectUrl,
      );
      _logger.info('Password reset email sent successfully');
    } catch (e) {
      _logger.severe('Password reset failed', e);
      throw 'Password reset failed: ${e.toString()}';
    }
  }

  /// Get the current user's session
  Session? getCurrentSession() {
    final session = supabase.auth.currentSession;
    _logger.info('Current session: ${session?.user.email ?? 'No session'}');
    return session;
  }

  /// Get the current user
  User? getCurrentUser() {
    if (_cachedUser != null) {
      return _cachedUser;
    }
    
    final user = supabase.auth.currentUser;
    _cachedUser = user;
    _logger.info('Current user: ${user?.email ?? 'No user'}');
    return user;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    final isAuth = supabase.auth.currentSession != null;
    _logger.info('Is authenticated: $isAuth');
    return isAuth;
  }

  /// Listen to auth state changes
  Stream<AuthState> onAuthStateChange() {
    _logger.info('Setting up auth state change listener');
    return supabase.auth.onAuthStateChange;
  }
  
  /// Refresh the current session
  Future<void> refreshSession() async {
    try {
      _logger.info('Refreshing session');
      final session = supabase.auth.currentSession;
      
      if (session == null) {
        _logger.warning('No active session to refresh');
        return;
      }
      
      if (session.isExpired) {
        _logger.info('Session expired, refreshing token');
        await supabase.auth.refreshSession();
        _logger.info('Session refreshed successfully');
      }
    } catch (e) {
      _logger.severe('Failed to refresh session', e);
      // Don't throw, just log the error
    }
  }
} 