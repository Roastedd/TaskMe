import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('SupabaseClient');
late SupabaseClient supabase;
bool _isInitialized = false;

/// Initialize the Supabase client with proper error handling
Future<void> initializeSupabase() async {
  if (_isInitialized) {
    _logger.info('Supabase client already initialized');
    return;
  }

  try {
    _logger.info('Initializing Supabase client with URL: ${Config.supabaseUrl}');
    
    await Supabase.initialize(
      url: Config.supabaseUrl,
      anonKey: Config.supabaseAnonKey,
      debug: kDebugMode,
    );
    
    supabase = Supabase.instance.client;
    _isInitialized = true;
    _logger.info('Supabase client initialized successfully');
  } catch (e, stackTrace) {
    _logger.severe('Failed to initialize Supabase client', e, stackTrace);
    rethrow;
  }
} 