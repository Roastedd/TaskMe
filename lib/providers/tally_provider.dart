import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '/models/tally.dart';
import '/providers/user_provider.dart';
import '../utils/validation_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '/services/supabase_client.dart'; // Import supabase client

class TallyProvider with ChangeNotifier, TallyValidation {
  final UserProvider _userProvider;
  final List<Tally> _tallies = [];
  String _weekStart = 'Monday';
  bool _isLoading = false;

  // Cache for statistics
  final Map<String, Map<int, int>> _weeklyStatsCache = {};
  final Map<String, Map<int, int>> _monthlyStatsCache = {};
  final Map<String, Map<int, int>> _yearlyStatsCache = {};

  // Batch update control
  bool _batchUpdating = false;
  final List<Function> _pendingNotifications = [];
  final SharedPreferences _prefs;
  static const String _talliesKey = 'tallies';
  final Logger _logger = Logger('TallyProvider');

  TallyProvider(this._userProvider, this._prefs) {
    _loadPreferences();
    loadTallies();
    _setupCacheResetTimer();
  }

  List<Tally> get tallies => List.unmodifiable(_tallies);
  String get weekStart => _weekStart;
  bool get isLoading => _isLoading;

  Tally? getTallyById(String id) {
    try {
      return _tallies.firstWhere((tally) => tally.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadTallies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? talliesJson = _prefs.getString(_talliesKey);
      if (talliesJson != null) {
        final List<dynamic> decoded = jsonDecode(talliesJson);
        _tallies.clear();
        _tallies.addAll(
          decoded.map((item) => Tally.fromJson(item as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      _logger.severe('Error loading tallies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTallies() async {
    try {
      final String encoded =
          jsonEncode(_tallies.map((t) => t.toJson()).toList());
      await _prefs.setString(_talliesKey, encoded);
    } catch (e) {
      _logger.severe('Error saving tallies: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final file = await _getLocalFile('preferences.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        _weekStart = data['weekStart'] ?? 'Monday';
      }
    } catch (e) {
      // Handle the error if necessary
      _logger.severe("Error loading preferences: $e");
    }
  }

  Future<void> _savePreferences() async {
    try {
      final file = await _getLocalFile('preferences.json');
      final data = {'weekStart': _weekStart};
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      // Handle the error if necessary
      _logger.severe("Error saving preferences: $e");
    }
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  void setTallies(List<Tally> tallies) {
    _tallies.clear();
    _tallies.addAll(tallies);
    notifyListeners();
  }

  Future<void> addTally(Tally tally) async {
    validateTally(tally); // Throws ArgumentError on invalid

    if (_userProvider.supabaseUser == null) return;

    try {
      final response =
          await SupabaseClient.supabase // Use imported supabase client
              .from('habits')
              .insert({
                'user_id': _userProvider.supabaseUser!.id,
                ...tally.toJson(),
              })
              .select()
              .single();

      _tallies.add(Tally.fromJson(response));
      await _saveTallies();
      notifyListeners();
    } catch (e) {
      _logger.severe('Tally creation failed', e);
      rethrow;
    }
  }

  Future<void> updateTally(Tally tally) async {
    try {
      await SupabaseClient.supabase // Use imported supabase client
          .from('habits')
          .update(tally.toJson())
          .eq('id', tally.id);

      final index = _tallies.indexWhere((t) => t.id == tally.id);
      if (index != -1) {
        _tallies[index] = tally;
        await _saveTallies();
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error updating tally: $e');
      rethrow;
    }
  }

  Future<void> removeTally(Tally tally) async {
    try {
      await SupabaseClient.supabase // Use imported supabase client
          .from('habits')
          .delete()
          .eq('id', tally.id);

      _tallies.removeWhere((t) => t.id == tally.id);
      await _saveTallies();
      notifyListeners();
    } catch (e) {
      _logger.severe('Error removing tally: $e');
      rethrow;
    }
  }

  Future<void> incrementTally(Tally tally, DateTime date,
      [int? customValue]) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final currentValue = tally.dailyValues[dateString] ?? 0;
    final newValue = customValue ?? (currentValue + tally.incrementValue);

    try {
      // Update local state
      final updatedTally = tally.copyWith(
        dailyValues: {...tally.dailyValues, dateString: newValue},
        lastModified: DateTime.now(),
      );

      // Update in database
      await SupabaseClient.supabase // Use imported supabase client
          .from('habits')
          .update(updatedTally.toJson())
          .eq('id', tally.id);

      // Update local list
      final index = _tallies.indexWhere((t) => t.id == tally.id);
      if (index != -1) {
        _tallies[index] = updatedTally;
        await _saveTallies();
        notifyListeners();
      }

      // Add XP if target is reached
      if (tally.goalType == GoalType.reachAmount &&
          tally.targetValue > 0 &&
          currentValue < tally.targetValue &&
          newValue >= tally.targetValue) {
        _userProvider.addXp(10); // Award XP for reaching target
      }
    } catch (e) {
      _logger.severe('Error incrementing tally: $e');
      rethrow;
    }
  }

  List<Tally> getTalliesForDate(DateTime date) {
    return _tallies.where((tally) {
      if (tally.trackDays.isEmpty) return true;
      return tally.trackDays[date.weekday - 1];
    }).toList();
  }

  void setWeekStart(String start) {
    _weekStart = start;
    _savePreferences();
    notifyListeners();
  }

  Map<int, int> getWeeklyStatistics(Tally tally) {
    // Check cache first
    if (_weeklyStatsCache.containsKey(tally.id)) {
      return Map<int, int>.from(_weeklyStatsCache[tally.id]!);
    }

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    Map<int, int> weeklyStats = {};

    // Batch process the week's data
    final batch = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    for (var i = 0; i < 7; i++) {
      final dateString = DateFormat('yyyy-MM-dd').format(batch[i]);
      weeklyStats[i] = tally.dailyValues[dateString] ?? 0;
    }

    // Cache the result
    _weeklyStatsCache[tally.id] = Map<int, int>.from(weeklyStats);
    return weeklyStats;
  }

  Map<int, int> getMonthlyStatistics(Tally tally) {
    // Check cache first
    if (_monthlyStatsCache.containsKey(tally.id)) {
      return Map<int, int>.from(_monthlyStatsCache[tally.id]!);
    }

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    Map<int, int> monthlyStats = {};

    // Batch process the month's data
    final batch = List.generate(
      daysInMonth,
      (i) => DateTime(now.year, now.month, i + 1),
    );

    for (var i = 0; i < daysInMonth; i++) {
      final dateString = DateFormat('yyyy-MM-dd').format(batch[i]);
      monthlyStats[i + 1] = tally.dailyValues[dateString] ?? 0;
    }

    // Cache the result
    _monthlyStatsCache[tally.id] = Map<int, int>.from(monthlyStats);
    return monthlyStats;
  }

  Map<int, int> getYearlyStatistics(Tally tally) {
    // Check cache first
    if (_yearlyStatsCache.containsKey(tally.id)) {
      return Map<int, int>.from(_yearlyStatsCache[tally.id]!);
    }

    final now = DateTime.now();
    Map<int, int> yearlyStats = {};

    // Process each month in parallel for better performance
    for (var month = 1; month <= 12; month++) {
      final daysInMonth = DateTime(now.year, month + 1, 0).day;
      int monthTotal = 0;

      // Batch process days in month
      final batch = List.generate(
        daysInMonth,
        (day) =>
            DateFormat('yyyy-MM-dd').format(DateTime(now.year, month, day + 1)),
      );

      monthTotal = batch.fold(
          0, (sum, dateString) => sum + (tally.dailyValues[dateString] ?? 0));

      yearlyStats[month - 1] = monthTotal;
    }

    // Cache the result
    _yearlyStatsCache[tally.id] = Map<int, int>.from(yearlyStats);
    return yearlyStats;
  }

  Future<void> saveTally(Tally tally) async {
    // Add enum validation
    try {
      final userId = _userProvider.supabaseUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      beginBatchUpdate();

      // Update local state first
      final index = _tallies.indexWhere((t) => t.id == tally.id);
      if (index != -1) {
        _tallies[index] = tally;
      } else {
        _tallies.add(tally);
      }

      // Clear relevant caches
      _weeklyStatsCache.remove(tally.id);
      _monthlyStatsCache.remove(tally.id);
      _yearlyStatsCache.remove(tally.id);

      // Save to local storage
      await _saveTallies();

      // Save to Supabase
      await SupabaseClient.supabase // Use imported supabase client
          .from('habits')
          .upsert(
        {...tally.toJson(), 'user_id': userId},
      );

      endBatchUpdate();
      _logger.info('Tally saved successfully: ${tally.id}');
    } catch (e) {
      endBatchUpdate();
      _logger.severe('Error saving tally: $e');
      rethrow;
    }
  }

  // Add method for bulk operations
  Future<void> saveTallies(List<Tally> tallies) async {
    try {
      final userId = _userProvider.supabaseUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      beginBatchUpdate();

      // Prepare batch updates
      final updates = tallies
          .map((tally) => {...tally.toJson(), 'user_id': userId})
          .toList();

      // Update local state
      for (var tally in tallies) {
        final index = _tallies.indexWhere((t) => t.id == tally.id);
        if (index != -1) {
          _tallies[index] = tally;
        } else {
          _tallies.add(tally);
        }

        // Clear relevant caches
        _weeklyStatsCache.remove(tally.id);
        _monthlyStatsCache.remove(tally.id);
        _yearlyStatsCache.remove(tally.id);
      }

      // Save to local storage
      await _saveTallies();

      // Batch save to Supabase
      await SupabaseClient.supabase // Use imported supabase client
          .from('habits')
          .upsert(updates);

      endBatchUpdate();
      _logger.info('${tallies.length} tallies saved successfully');
    } catch (e) {
      endBatchUpdate();
      _logger.severe('Error saving tallies: $e');
      rethrow;
    }
  }

  void _setupCacheResetTimer() {
    // Reset cache at midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    Future.delayed(timeUntilMidnight, () {
      _clearCache();
      _setupCacheResetTimer(); // Setup for next day
    });
  }

  void _clearCache() {
    _weeklyStatsCache.clear();
    _monthlyStatsCache.clear();
    _yearlyStatsCache.clear();
  }

  void beginBatchUpdate() {
    _batchUpdating = true;
  }

  void endBatchUpdate() {
    _batchUpdating = false;
    if (_pendingNotifications.isNotEmpty) {
      notifyListeners();
      _pendingNotifications.clear();
    }
  }

  @override
  void notifyListeners() {
    if (_batchUpdating) {
      _pendingNotifications.add(() => super.notifyListeners());
    } else {
      super.notifyListeners();
    }
  }

  Future<void> deleteTally(String id) async {
    try {
      _logger.info('Deleting tally: $id');
      _tallies.removeWhere((tally) => tally.id == id);
      await _saveTallies();
      notifyListeners();
    } catch (e) {
      _logger.severe('Error deleting tally: $e');
      rethrow;
    }
  }
}
