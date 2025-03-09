import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class Config {
  static final _logger = Logger('Config');
  
  static String get supabaseUrl => 
    dotenv.env['SUPABASE_URL'] ?? 'https://hkjagszkbwvvwzzvlvlp.supabase.co';
  
  static String get supabaseAnonKey =>
    dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhramFnc3prYnd2dnd6enZsdmxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk4NTQ0MTcsImV4cCI6MjAyNTQzMDQxN30.RK_cEgXyxCNr4mvKgXfpFBUkOjNX4FagYRe7-VY5DYE';
  
  // Deep linking configuration
  static const String scheme = 'io.supabase.taskme';
  static const String host = 'login-callback';
  
  // Get the appropriate redirect URL based on platform
  static String get redirectUrl {
    if (kIsWeb) {
      return '$supabaseUrl/auth/v1/callback';
    }
    
    // For mobile platforms, use custom URL scheme
    const url = '$scheme://$host/';
    _logger.info('Using redirect URL: $url');
    return url;
  }
  
  // Google OAuth Client IDs
  static const String iosGoogleClientId = '75977774800-bcu9perem41q2l40qj81oh48j9g0eeeo.apps.googleusercontent.com';
  static const String webGoogleClientId = '75977774800-i9f076j5esfh8lo4ke1idfi486sft5nv.apps.googleusercontent.com';
  
  // Get the appropriate Google Client ID based on platform
  static String get googleClientId {
    if (Platform.isIOS) {
      _logger.info('Using iOS Google Client ID: $iosGoogleClientId');
      return iosGoogleClientId;
    }
    _logger.info('Using web Google Client ID: $webGoogleClientId');
    return webGoogleClientId;
  }
  
  // Initialize environment variables
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
      _logger.info('Environment variables loaded successfully');
      _logger.info('Supabase URL: $supabaseUrl');
      _logger.info('Platform: ${Platform.operatingSystem}');
      _logger.info('Redirect URL: $redirectUrl');
      _logger.info('Google Client ID: $googleClientId');
    } catch (e) {
      _logger.warning('Failed to load .env file. Using default values.', e);
    }
  }
} 