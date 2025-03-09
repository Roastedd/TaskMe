import 'package:flutter/material.dart';

class Level {
  final int level;
  final int xpNeeded;
  final int maxTasks;
  final List<Color> availableColors;
  final String name;

  const Level({
    required this.level,
    required this.xpNeeded,
    required this.maxTasks,
    required this.availableColors,
    required this.name,
  });

  static final List<Level> levels = [
    const Level(
      level: 1,
      xpNeeded: 0,
      maxTasks: 5,
      availableColors: [Color(0xFF2196F3)],
      name: 'Beginner',
    ),
    const Level(
      level: 2,
      xpNeeded: 100,
      maxTasks: 10,
      availableColors: [Color(0xFF4CAF50)],
      name: 'Intermediate',
    ),
    const Level(
      level: 3,
      xpNeeded: 300,
      maxTasks: 15,
      availableColors: [Color(0xFFF44336)],
      name: 'Advanced',
    ),
    const Level(
      level: 4,
      xpNeeded: 600,
      maxTasks: 20,
      availableColors: [Color(0xFF9C27B0)],
      name: 'Expert',
    ),
    const Level(
      level: 5,
      xpNeeded: 1000,
      maxTasks: 25,
      availableColors: [Color(0xFFFF9800)],
      name: 'Master',
    )
  ];

  static Level getLevelForPoints(int points) {
    for (var i = levels.length - 1; i >= 0; i--) {
      if (points >= levels[i].xpNeeded) {
        return levels[i];
      }
    }
    return levels.first;
  }

  static int getNextLevelPoints(int points) {
    for (var level in levels) {
      if (points < level.xpNeeded) {
        return level.xpNeeded;
      }
    }
    return levels.last.xpNeeded;
  }

  static double getProgressToNextLevel(int points) {
    if (points >= levels.last.xpNeeded) {
      return 1.0;
    }

    final currentLevel = getLevelForPoints(points);
    final nextLevel = levels[levels.indexOf(currentLevel) + 1];

    final pointsInCurrentLevel = points - currentLevel.xpNeeded;
    final pointsNeededForNextLevel = nextLevel.xpNeeded - currentLevel.xpNeeded;

    return pointsInCurrentLevel / pointsNeededForNextLevel;
  }
}
