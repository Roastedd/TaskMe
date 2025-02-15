import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '/models/tally.dart';
import '/providers/user_provider.dart';

class TallyProvider with ChangeNotifier {
  List<Tally> _tallies = [];
  UserProvider userProvider;
  String _weekStart = 'Sunday';

  TallyProvider(this.userProvider) {
    _loadPreferences();
    loadTallies();
  }

  List<Tally> get tallies => _tallies;
  String get weekStart => _weekStart;

  Future<void> loadTallies() async {
    try {
      final file = await _getLocalFile('tallies.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> talliesJson = jsonDecode(contents);
        _tallies = talliesJson.map((json) => Tally.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle the error if necessary
      debugPrint("Error loading tallies: $e");
    }
  }

  Future<void> _saveTallies() async {
    try {
      final file = await _getLocalFile('tallies.json');
      final contents = jsonEncode(_tallies.map((tally) => tally.toJson()).toList());
      await file.writeAsString(contents);
      print('Tallies saved to file.');
    } catch (e) {
      // Handle the error if necessary
      debugPrint("Error saving tallies: $e");
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final file = await _getLocalFile('preferences.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        _weekStart = data['weekStart'] ?? 'Sunday';
      }
    } catch (e) {
      // Handle the error if necessary
      debugPrint("Error loading preferences: $e");
    }
  }

  Future<void> _savePreferences() async {
    try {
      final file = await _getLocalFile('preferences.json');
      final data = {'weekStart': _weekStart};
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      // Handle the error if necessary
      print("Error saving preferences: $e");
    }
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  void setTallies(List<Tally> tallies) {
    _tallies = tallies;
    notifyListeners();
  }

  void addTally(Tally tally) async {
    if (userProvider.canAddTask(_tallies.length)) {
      _tallies.add(tally);
      userProvider.addXp(1);
      await _saveTallies();
      notifyListeners();
      print('Tally added and saved. Total tallies: ${_tallies.length}');
    }
  }

  void incrementTally(Tally tally, DateTime date, [int? customIncrement]) async {
    final index = _tallies.indexOf(tally);
    if (index != -1) {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final incrementValue = customIncrement ?? tally.incrementValue;
      final updatedDailyValues = Map<String, int>.from(_tallies[index].dailyValues);
      updatedDailyValues.update(
        dateString,
            (value) => value + incrementValue,
        ifAbsent: () => incrementValue,
      );

      int xp = tally.xp + incrementValue;
      int level = tally.level;
      if (xp >= level * 100) {
        xp -= level * 100;
        level += 1;
      }

      _tallies[index] = _tallies[index].copyWith(
        dailyValues: updatedDailyValues,
        lastModified: DateTime.now(),
        xp: xp,
        level: level,
      );
      await _saveTallies();
      notifyListeners();
      print('Tally updated and saved. Tally ID: ${tally.id}');
    }
  }

  void updateTally(Tally updatedTally) async {
    final index = _tallies.indexWhere((tally) => tally.id == updatedTally.id);
    if (index != -1) {
      _tallies[index] = updatedTally;
      await _saveTallies();
      notifyListeners();
      print('Tally updated and saved. Tally ID: ${updatedTally.id}');
    }
  }

  void removeTally(Tally tally) async {
    _tallies.removeWhere((t) => t.id == tally.id);
    await _saveTallies();
    notifyListeners();
  }

  List<Tally> getTalliesForDate(DateTime date) {
    resetTalliesIfNeeded(date);
    return _tallies.where((tally) {
      if (tally.resetInterval == 'Daily') {
        return tally.trackDays[date.weekday % 7];
      } else if (tally.resetInterval == 'Weekly') {
        return tally.trackDays[date.weekday % 7] && _calculateWeeklyFrequency(tally, date);
      } else if (tally.resetInterval == 'Interval') {
        return _calculateIntervalFrequency(tally, date);
      }
      return true;
    }).toList();
  }

  bool _calculateWeeklyFrequency(Tally tally, DateTime date) {
    int count = 0;
    DateTime current = DateTime.now();
    while (current.isAfter(date)) {
      if (tally.trackDays[current.weekday % 7]) {
        count++;
      }
      current = current.subtract(const Duration(days: 1));
    }
    return count < tally.weeklyFrequency;
  }

  bool _calculateIntervalFrequency(Tally tally, DateTime date) {
    return date.difference(tally.startDate).inDays % tally.intervalFrequency == 0;
  }

  void resetTalliesIfNeeded(DateTime date) {
    bool anyTallyReset = false;
    for (var tally in _tallies) {
      bool shouldReset = false;
      switch (tally.resetInterval) {
        case 'Day':
          shouldReset = isNextDay(tally.lastResetDate, date);
          break;
        case 'Week':
          shouldReset = isNextWeek(tally.lastResetDate, date);
          break;
        case 'Month':
          shouldReset = isNextMonth(tally.lastResetDate, date);
          break;
        case 'Year':
          shouldReset = isNextYear(tally.lastResetDate, date);
          break;
      }

      if (shouldReset) {
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        if (!tally.dailyValues.containsKey(dateString)) {
          tally.dailyValues[dateString] = 0;
          tally.lastResetDate = date;
          anyTallyReset = true;
        }
      }
    }
    if (anyTallyReset) {
      _saveTallies();
      notifyListeners();
    }
  }

  bool isNextDay(DateTime lastResetDate, DateTime date) {
    return DateFormat('yyyy-MM-dd').format(lastResetDate) != DateFormat('yyyy-MM-dd').format(date);
  }

  bool isNextWeek(DateTime lastResetDate, DateTime date) {
    final lastResetWeek = _getWeekNumber(lastResetDate);
    final currentWeek = _getWeekNumber(date);
    return lastResetWeek != currentWeek || lastResetDate.year != date.year;
  }

  bool isNextMonth(DateTime lastResetDate, DateTime date) {
    return lastResetDate.month != date.month || lastResetDate.year != date.year;
  }

  bool isNextYear(DateTime lastResetDate, DateTime date) {
    return lastResetDate.year != date.year;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  void updateUserProvider(UserProvider userProvider) {
    this.userProvider = userProvider;
  }

  void setWeekStart(String value) {
    _weekStart = value;
    _savePreferences();
    notifyListeners();
  }

  Map<int, int> getWeeklyStatistics(Tally tally) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    Map<int, int> weeklyStats = {};

    for (var i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dateString = DateFormat('yyyy-MM-dd').format(day);
      weeklyStats[i] = tally.dailyValues[dateString] ?? 0;
    }

    return weeklyStats;
  }

  Map<int, int> getMonthlyStatistics(Tally tally) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    Map<int, int> monthlyStats = {};

    for (var i = 1; i <= daysInMonth; i++) {
      final day = DateTime(now.year, now.month, i);
      final dateString = DateFormat('yyyy-MM-dd').format(day);
      monthlyStats[i] = tally.dailyValues[dateString] ?? 0;
    }

    return monthlyStats;
  }

  Map<int, int> getYearlyStatistics(Tally tally) {
    final now = DateTime.now();
    Map<int, int> yearlyStats = {};

    for (var i = 1; i <= 12; i++) {
      final daysInMonth = DateTime(now.year, i + 1, 0).day;
      int monthTotal = 0;

      for (var j = 1; j <= daysInMonth; j++) {
        final day = DateTime(now.year, i, j);
        final dateString = DateFormat('yyyy-MM-dd').format(day);
        monthTotal += tally.dailyValues[dateString] ?? 0;
      }

      yearlyStats[i - 1] = monthTotal;
    }

    return yearlyStats;
  }
}
