import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClient {
  static final supabase = Supabase.instance.client;

  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Data methods
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', supabase.auth.currentUser?.id ?? '');
    return response;
  }

  static Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    await supabase.from('tasks').insert({
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'user_id': supabase.auth.currentUser?.id ?? '',
      'completed': false,
    });
  }

  static Future<void> updateTask({
    required int taskId,
    required Map<String, dynamic> updates,
  }) async {
    await supabase
        .from('tasks')
        .update(updates)
        .eq('id', taskId)
        .eq('user_id', supabase.auth.currentUser?.id ?? '');
  }

  static Future<void> deleteTask(int taskId) async {
    await supabase
        .from('tasks')
        .delete()
        .eq('id', taskId)
        .eq('user_id', supabase.auth.currentUser?.id ?? '');
  }
}
