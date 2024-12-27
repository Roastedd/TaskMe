import 'package:flutter/material.dart';

class Level {
  final int level;
  final int xpNeeded;
  final int maxTasks;
  final List<int> availableColors;

  Level(this.level, this.xpNeeded, this.maxTasks, this.availableColors);
}

final List<Level> levels = [
  Level(1, 0, 10, [Colors.red.value, Colors.green.value, Colors.blue.value]),
  Level(2, 100, 100, [Colors.red.value, Colors.green.value, Colors.blue.value, Colors.yellow.value, Colors.purple.value]),
  // Add more levels as needed
];