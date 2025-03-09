import 'package:flutter/material.dart';
import '../models/tally.dart';

mixin TallyValidation {
  final formKey = GlobalKey<FormState>();

  void validateTally(Tally tally) {
    // Core property validations
    if (tally.title.isEmpty || tally.title.length > 50) {
      throw ArgumentError('Name must be 2-50 characters');
    }

    // Increment value validation
    if (tally.incrementValue < 1 || tally.incrementValue > 100) {
      throw ArgumentError('Enter value between 1-100');
    }

    // Custom duration validation
    if (tally.durationOption == DurationOption.custom &&
        tally.customDuration == null) {
      throw ArgumentError('Specify custom duration');
    }

    // Track days validation
    if (!tally.trackDays.contains(true)) {
      throw ArgumentError('Select at least one tracking day');
    }

    // Goal validation
    if (tally.targetValue < 0 || tally.targetValue > 9999) {
      throw ArgumentError('Target value must be between 0-9999');
    }

    // Level validation
    if (tally.level < 1 || tally.level > 100) {
      throw ArgumentError('Level must be between 1-100');
    }

    // XP validation
    if (tally.xp < 0 || tally.xp > 999999) {
      throw ArgumentError('XP must be between 0-999999');
    }
  }

  String? validateTitle(String? title) {
    if (title == null || title.isEmpty) {
      return 'Title is required';
    }
    if (title.length < 2) {
      return 'Title must be at least 2 characters';
    }
    if (title.length > 50) {
      return 'Title must be less than 50 characters';
    }
    return null;
  }

  String? validateIncrementValue(int? value) {
    if (value == null) {
      return 'Increment value is required';
    }
    if (value < 1 || value > 100) {
      return 'Enter value between 1-100';
    }
    return null;
  }

  String? validateTargetValue(int? value) {
    if (value == null) return null; // Target is optional
    if (value < 0 || value > 9999) {
      return 'Target must be between 0-9999';
    }
    return null;
  }

  String? validateCustomDuration(DurationOption option, int? value) {
    if (option == DurationOption.custom && value == null) {
      return 'Specify custom duration';
    }
    if (value != null && (value < 1 || value > 365)) {
      return 'Duration must be between 1-365 days';
    }
    return null;
  }

  String? validateTrackDays(List<bool> days) {
    if (!days.contains(true)) {
      return 'Select at least one tracking day';
    }
    return null;
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}

mixin ValidationMixin {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
