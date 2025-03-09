import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import '/providers/theme_notifier.dart';
import '/providers/notification_helper.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  final _logger = Logger('TimerScreenState'); // Create a logger instance
  Duration _duration = const Duration(hours: 0, minutes: 0, seconds: 0);
  bool _isRunning = false;
  bool _isEditing = false;
  late Duration _remaining;
  List<Duration> _recents = [];
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _logger.info('Timer Screen init');
    _remaining = _duration;
    _controller = AnimationController(vsync: this, duration: _duration);
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _loadRecents();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startTimer() async {
    setState(() {
      _isRunning = true;
      if (!_recents.contains(_duration)) {
        _recents.add(_duration);
        _saveRecents();
      }
      _controller.duration = _duration;
      _controller.reverse(from: 1.0);
    });
    _remaining = _duration;

    // Cancel any existing notifications first
    await NotificationHelper().cancelNotification(0);
    
    // Schedule the notification for when the timer completes
    await NotificationHelper().scheduleNotification(
      0,
      'Timer Finished',
      'Your countdown timer is complete.',
      DateTime.now().add(_duration),
    );

    Future.doWhile(() async {
      if (_remaining.inSeconds > 0 && _isRunning) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
        return true;
      } else {
        setState(() {
          _isRunning = false;
        });
        if (_remaining.inSeconds == 0) {
          await NotificationHelper().showTimerNotification(
            0,
            'Timer Finished',
            'Your countdown timer is complete.',
          );
        }
        return false;
      }
    });
  }

  Future<void> _stopTimer() async {
    setState(() {
      _isRunning = false;
      _controller.stop();
    });
    // Make sure to cancel the notification when the timer is stopped
    await NotificationHelper().cancelNotification(0);
  }

  void _setPreset(Duration preset) {
    setState(() {
      _duration = preset;
      _remaining = _duration;
      _controller.duration = _duration;
    });
  }

  Future<void> _startPresetTimer(Duration preset) async {
    _setPreset(preset);
    await _startTimer();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _deleteRecent(int index) {
    setState(() {
      _recents.removeAt(index);
      _saveRecents();
    });
  }

  void _deleteAllRecents() {
    setState(() {
      _recents.clear();
      _saveRecents();
    });
  }

  Future<void> _loadRecents() async {
    try {
      final file = await _getLocalFile('recents.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> recentsData = jsonDecode(contents);
        _recents = recentsData.map((data) => Duration(seconds: data)).toList();
      }
      setState(() {});
    } catch (e) {
      _logger.severe("Error loading recents: $e");
    }
  }

  Future<void> _saveRecents() async {
    try {
      final file = await _getLocalFile('recents.json');
      final contents = jsonEncode(_recents.map((duration) => duration.inSeconds).toList());
      await file.writeAsString(contents);
    } catch (e) {
      _logger.severe("Error saving recents: $e");
    }
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);
    const textColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timers'),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _toggleEditing,
            child: Text(_isEditing ? 'Done' : 'Edit', style: const TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _isRunning
              ? Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _animation.value,
                          strokeWidth: 10,
                          color: Colors.orange,
                        );
                      },
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Text(
                        _remaining.toString().split('.').first.padLeft(8, '0'),
                        style: const TextStyle(fontSize: 36, color: textColor),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                brightness: Brightness.dark,
                primaryColor: Colors.white,
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoTimerPicker(
                  initialTimerDuration: _duration,
                  mode: CupertinoTimerPickerMode.hms,
                  onTimerDurationChanged: (Duration changedTimer) {
                    setState(() {
                      _duration = changedTimer;
                      _remaining = _duration;
                      _controller.duration = _duration;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isRunning ? _stopTimer : null,
                    icon: const Icon(Icons.cancel, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isRunning ? () async {
                      await _stopTimer();
                    } : () async {
                      await _startTimer();
                    },
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_isEditing)
            TextButton(
              onPressed: _deleteAllRecents,
              child: const Text('Delete All Recents', style: TextStyle(color: Colors.red)),
            ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Recents', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recents.length,
              itemBuilder: (context, index) {
                final duration = _recents[_recents.length - 1 - index];
                return ListTile(
                  title: Text(
                    duration.toString().split('.').first.padLeft(8, '0'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${duration.inMinutes} min, ${duration.inSeconds % 60} sec',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRecent(_recents.length - 1 - index),
                  )
                      : IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () => _startPresetTimer(duration),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
