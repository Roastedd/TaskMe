import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/level.dart';
import '../services/auth_service.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';

class AppUser {
  int xp;
  int level;

  AppUser(this.xp, this.level) {
    // Ensure level is never less than 1
    if (level < 1) level = 1;
  }
}

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _logger = Logger('UserProvider');
  late final SupabaseClient _supabase;
  User? _supabaseUser;
  bool _isLoading = false;
  final AppUser _appUser = AppUser(0, 1);
  Exception? _lastAuthError;
  Exception? get lastAuthError => _lastAuthError;
  bool get hasError => _lastAuthError != null;
  StreamSubscription<AuthState>? _authSubscription;

  User? get supabaseUser => _supabaseUser;
  AppUser get appUser => _appUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initializeSupabase();
  }

  void _initializeSupabase() {
    try {
      _supabase = Supabase.instance.client;
      _supabaseUser = _supabase.auth.currentUser;
      _logger
          .info('UserProvider initialized with user: ${_supabaseUser?.email}');

      _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
        _logger.info('Auth state changed: ${data.event}');
        _supabaseUser = data.session?.user;

        if (data.event == AuthChangeEvent.signedIn) {
          _logger.info('User signed in: ${_supabaseUser?.email}');
        } else if (data.event == AuthChangeEvent.signedOut) {
          _logger.info('User signed out');
        } else if (data.event == AuthChangeEvent.userUpdated) {
          _logger.info('User updated: ${_supabaseUser?.email}');
        }

        notifyListeners();
      });
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize UserProvider', e, stackTrace);
      _lastAuthError = e is Exception ? e : Exception(e.toString());
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        _logger.info('User signed up: ${user.email}');
        return true;
      }
      return false;
    } catch (e) {
      _logger.severe('Sign up failed', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _lastAuthError = null;
      _isLoading = true;
      notifyListeners();

      final redirectUrl = Config.redirectUrl;
      _logger.info('Starting Google sign in with redirect URL: $redirectUrl');

      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        queryParams: {
          'prompt': 'select_account',
          'access_type': 'offline',
          'client_id': Config.googleClientId,
        },
        authScreenLaunchMode: LaunchMode.inAppWebView,
      );

      if (!response) {
        _logger.warning('Google sign in failed - no response');
        return false;
      }

      _logger.info('Google sign in initiated successfully');

      // Clear any cached user data
      _supabaseUser = null;

      // Wait for auth state to change
      bool authenticated = false;
      int attempts = 0;
      const maxAttempts = 30;

      while (!authenticated && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          final session = _supabase.auth.currentSession;
          if (session != null) {
            _logger.info('Successfully got session after Google sign in');
            _supabaseUser = session.user;
            authenticated = true;
            notifyListeners();
            return true;
          }
        } catch (e) {
          _logger.warning('Error checking session: $e');
        }

        attempts++;
        _logger
            .info('Waiting for session... Attempt $attempts of $maxAttempts');
      }

      if (!authenticated) {
        _logger.warning('Failed to get session after Google sign in');
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      _lastAuthError = e is Exception ? e : Exception(e.toString());
      _logger.severe('Google sign in failed', e, stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
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
    return Level.getLevelForPoints(_appUser.xp);
  }

  void addXp(int xp) {
    if (xp < 0) return;

    _appUser.xp += xp;

    // Update level based on XP
    _appUser.level = Level.getLevelForPoints(_appUser.xp).level;

    notifyListeners();
  }

  bool canAddTask(int currentTasksCount) => true; // Always allow adding tasks

  List<int> get availableColors => [
        0xFF49A6A6,
        0xFF5FC25F,
        0xFFF08080,
        0xFFFFD700,
        0xFFBA55D3,
      ]; // Default available colors

  Future<void> validateSession() async {
    try {
      final currentSession = _supabase.auth.currentSession;

      if (currentSession?.user.id != _supabaseUser?.id) {
        _logger.warning('Session validation failed - forcing logout');
        await signOut();
      }
    } catch (e) {
      _logger.severe('Session validation error', e);
      await signOut();
    }
  }

  int get requiredPoints {
    if (_supabaseUser != null) {
      final level = Level.getLevelForPoints(_appUser.xp);
      return level.xpNeeded;
    }
    return 0;
  }

  double get progressToNextLevel {
    if (_supabaseUser != null) {
      return Level.getProgressToNextLevel(_appUser.xp);
    }
    return -1;
  }

  Future<void> refreshSession() async {
    try {
      final currentSession = _supabase.auth.currentSession;
      if (currentSession != null) {
        await _supabase.auth.refreshSession();
        _logger.info('Session refreshed successfully');
      }
    } catch (e) {
      _logger.severe('Session refresh failed', e);
      await signOut();
    }
  }
}
