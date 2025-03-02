import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

class ThemeNotifier with ChangeNotifier {
  final _logger = Logger('ThemeNotifier'); // Create a logger instance
  final String key = "theme";
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    _logger.info('Theme Notifier constructed');
    _loadFromPrefs();
  }

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    _saveToPrefs();
    _logger.info('Theme changed to: ${isDark ? 'dark' : 'light'}');
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final file = await _getLocalFile('theme.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        _isDarkMode = data[key] ?? false;
      }
      notifyListeners();
    } catch (e) {
      // Handle the error if necessary
      _logger.severe("Error loading theme preferences: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final file = await _getLocalFile('theme.json');
      final data = {key: _isDarkMode};
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      // Handle the error if necessary
      _logger.severe("Error saving theme preferences: $e");
    }
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }
}
