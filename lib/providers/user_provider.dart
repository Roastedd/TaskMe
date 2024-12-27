import 'package:flutter/material.dart';
import '/models/level.dart';

class AppUser {
  int xp;
  int level;

  AppUser(this.xp, this.level);
}

class UserProvider with ChangeNotifier {
  final AppUser _user = AppUser(0, 1);

  AppUser get user => _user;

  Level get currentLevel => levels[_user.level - 1];

  void addXp(int xp) {
    _user.xp += xp;
    if (_user.xp >= levels[_user.level].xpNeeded) {
      _user.level++;
    }
    notifyListeners();
  }

  bool canAddTask(int currentTasksCount) => currentTasksCount < currentLevel.maxTasks;

  List<int> get availableColors => currentLevel.availableColors;
}
