import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? 'https://hkjagszkbwvvwzzvlvlp.supabase.co';
  
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhramFnc3prYnd2dnd6enZsdmxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0NDg5ODUsImV4cCI6MjA1NjAyNDk4NX0.QtDyvkey3IaPEanWP3I2ErdvC49lRPUpgGRXtN7nSOU';
} 