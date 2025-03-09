import 'dart:convert';
import 'package:uuid/uuid.dart';

enum GoalType { achieveAll, reachAmount, stayUnder }

// Define the DurationOption enum
enum DurationOption {
  minutes,
  hours,
  custom,
  days7,
  days21,
  days30,
  days100,
  days365,
  forever
}

enum UnitType {
  times('times'),
  minutes('minutes'),
  hours('hours'),
  kilometers('kilometers'),
  miles('miles'),
  calories('calories'),
  glasses('glasses'),
  custom('custom');

  final String displayName;
  const UnitType(this.displayName);
}

extension UnitTypeExtension on UnitType {
  String get displayName => this.displayName;
}

// Add proper reset interval enum
enum ResetInterval { daily, weekly, interval }

extension DurationOptionExtension on DurationOption {
  String get displayName {
    switch (this) {
      case DurationOption.days7:
        return '7 Days';
      case DurationOption.days21:
        return '21 Days';
      case DurationOption.days30:
        return '30 Days';
      case DurationOption.days100:
        return '100 Days';
      case DurationOption.days365:
        return '365 Days';
      case DurationOption.forever:
        return 'Forever';
      default:
        return toString().split('.').last;
    }
  }
}

class Tally {
  // Core Properties
  final String id;
  final String title;
  final int color;

  // Tracking Configuration
  final ResetInterval resetInterval;
  final List<bool> trackDays;
  final int incrementValue;

  // Goal System
  final GoalType goalType;
  final int targetValue;
  final UnitType unitType;

  // Progression
  final int xp;
  final int level;

  // Duration Options
  final DurationOption durationOption;
  final int? customDuration;

  // Metadata
  final DateTime lastModified;
  final DateTime startDate;
  final Map<String, int> dailyValues;

  final bool showQuoteInsteadOfTime;

  final String? quote;

  final bool setTarget;

  final int weeklyFrequency;

  final int intervalFrequency;

  final List<DateTime> reminderTimes;

  final String goalTypeString;

  Tally({
    String? id,
    required this.title,
    required this.color,
    required this.resetInterval,
    required this.trackDays,
    required this.incrementValue,
    required this.goalType,
    required this.targetValue,
    required this.unitType,
    this.xp = 0,
    this.level = 1,
    required this.durationOption,
    this.customDuration,
    DateTime? lastModified,
    DateTime? startDate,
    Map<String, int>? dailyValues,
    this.showQuoteInsteadOfTime = false,
    this.quote,
    this.setTarget = false,
    this.weeklyFrequency = 1,
    this.intervalFrequency = 1,
    this.reminderTimes = const [],
  })  : assert(title.length >= 2 && title.length <= 50,
            'Title must be 2-50 characters'),
        assert(incrementValue >= 1 && incrementValue <= 100,
            'Increment value must be 1-100'),
        assert(targetValue >= 0 && targetValue <= 9999,
            'Target value must be 0-9999'),
        assert(xp >= 0 && xp <= 999999, 'XP must be 0-999999'),
        assert(level >= 1 && level <= 100, 'Level must be 1-100'),
        assert(trackDays.length == 7, 'Must specify 7 days'),
        assert(trackDays.contains(true), 'Must track at least one day'),
        assert(
            !(durationOption == DurationOption.custom &&
                customDuration == null),
            'Custom duration required when option is custom'),
        id = id ?? const Uuid().v4(),
        lastModified = lastModified ?? DateTime.now(),
        startDate = startDate ?? DateTime.now(),
        dailyValues = dailyValues ?? {},
        goalTypeString = goalType.toString().split('.').last;

  factory Tally.fromJson(Map<String, dynamic> json) {
    return Tally(
      id: json['id'] as String,
      title: json['title'] as String,
      color: json['color'] as int,
      resetInterval: ResetInterval.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (json['resetInterval'] as String),
        orElse: () => ResetInterval.daily,
      ),
      trackDays: (json['trackDays'] as List).cast<bool>(),
      incrementValue: json['incrementValue'] as int,
      goalType: GoalType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['goalType'] as String),
        orElse: () => GoalType.achieveAll,
      ),
      targetValue: json['targetValue'] as int,
      unitType: UnitType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['unitType'] as String),
        orElse: () => UnitType.times,
      ),
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      durationOption: DurationOption.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (json['durationOption'] as String),
        orElse: () => DurationOption.days30,
      ),
      customDuration: json['customDuration'] as int?,
      lastModified: DateTime.parse(json['lastModified'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      dailyValues: (json['dailyValues'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      showQuoteInsteadOfTime: json['showQuoteInsteadOfTime'] as bool? ?? false,
      quote: json['quote'] as String?,
      setTarget: json['setTarget'] as bool? ?? false,
      weeklyFrequency: json['weeklyFrequency'] as int? ?? 1,
      intervalFrequency: json['intervalFrequency'] as int? ?? 1,
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'color': color,
        'resetInterval': resetInterval.toString().split('.').last,
        'trackDays': trackDays,
        'incrementValue': incrementValue,
        'goalType': goalType.toString().split('.').last,
        'targetValue': targetValue,
        'unitType': unitType.toString().split('.').last,
        'xp': xp,
        'level': level,
        'durationOption': durationOption.toString().split('.').last,
        'customDuration': customDuration,
        'lastModified': lastModified.toIso8601String(),
        'startDate': startDate.toIso8601String(),
        'dailyValues': dailyValues,
        'showQuoteInsteadOfTime': showQuoteInsteadOfTime,
        'quote': quote,
        'setTarget': setTarget,
        'weeklyFrequency': weeklyFrequency,
        'intervalFrequency': intervalFrequency,
        'reminderTimes': reminderTimes.map((e) => e.toIso8601String()).toList(),
      };

  Tally copyWith({
    String? id,
    String? title,
    int? color,
    ResetInterval? resetInterval,
    List<bool>? trackDays,
    int? incrementValue,
    GoalType? goalType,
    int? targetValue,
    UnitType? unitType,
    int? xp,
    int? level,
    DurationOption? durationOption,
    int? customDuration,
    DateTime? lastModified,
    DateTime? startDate,
    Map<String, int>? dailyValues,
    bool? showQuoteInsteadOfTime,
    String? quote,
    bool? setTarget,
    int? weeklyFrequency,
    int? intervalFrequency,
    List<DateTime>? reminderTimes,
  }) {
    return Tally(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      resetInterval: resetInterval ?? this.resetInterval,
      trackDays: trackDays ?? List.from(this.trackDays),
      incrementValue: incrementValue ?? this.incrementValue,
      goalType: goalType ?? this.goalType,
      targetValue: targetValue ?? this.targetValue,
      unitType: unitType ?? this.unitType,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      durationOption: durationOption ?? this.durationOption,
      customDuration: customDuration ?? this.customDuration,
      lastModified: lastModified ?? this.lastModified,
      startDate: startDate ?? this.startDate,
      dailyValues: dailyValues ?? Map.from(this.dailyValues),
      showQuoteInsteadOfTime:
          showQuoteInsteadOfTime ?? this.showQuoteInsteadOfTime,
      quote: quote ?? this.quote,
      setTarget: setTarget ?? this.setTarget,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      intervalFrequency: intervalFrequency ?? this.intervalFrequency,
      reminderTimes: reminderTimes ?? List.from(this.reminderTimes),
    );
  }

  bool shouldTrackOnDate(DateTime date) {
    if (date.isBefore(startDate)) return false;
    return trackDays[date.weekday - 1];
  }

  int getValueForDate(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyValues[dateKey] ?? 0;
  }

  bool hasReachedTarget(DateTime date) {
    return getValueForDate(date) >= targetValue;
  }

  Duration getRemainingDuration() {
    switch (durationOption) {
      case DurationOption.custom:
        return Duration(days: customDuration ?? 0);
      case DurationOption.days7:
        return const Duration(days: 7);
      case DurationOption.days21:
        return const Duration(days: 21);
      case DurationOption.days30:
        return const Duration(days: 30);
      case DurationOption.days100:
        return const Duration(days: 100);
      case DurationOption.days365:
        return const Duration(days: 365);
      case DurationOption.forever:
        return const Duration(days: 36500); // 100 years
      default:
        return const Duration(days: 30);
    }
  }

  static DurationOption durationOptionFromString(String value) {
    return DurationOption.values.firstWhere(
      (e) => e.toString().split('.').last == value.toLowerCase(),
      orElse: () => DurationOption.minutes,
    );
  }

  static String resetIntervalFromString(String value) {
    return ResetInterval.values
        .firstWhere(
          (e) => e.toString().split('.').last == value.toLowerCase(),
          orElse: () => ResetInterval.daily,
        )
        .toString()
        .split('.')
        .last;
  }

  static String unitTypeFromString(String value) {
    return UnitType.values
        .firstWhere(
          (e) => e.toString().split('.').last == value,
          orElse: () => UnitType.times,
        )
        .toString()
        .split('.')
        .last;
  }

  // Validation
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length < 2 || value.length > 50) {
      return 'Title must be between 2 and 50 characters';
    }
    return null;
  }

  static String? validateIncrementValue(int? value) {
    if (value == null) {
      return 'Increment value is required';
    }
    if (value < 1 || value > 100) {
      return 'Increment value must be between 1 and 100';
    }
    return null;
  }

  static String? validateTargetValue(int? value) {
    if (value == null) {
      return 'Target value is required';
    }
    if (value < 0 || value > 9999) {
      return 'Target value must be between 0 and 9999';
    }
    return null;
  }

  static String? validateCustomDuration(DurationOption option, int? value) {
    if (option == DurationOption.custom) {
      if (value == null) {
        return 'Custom duration is required';
      }
      if (value < 1 || value > 365) {
        return 'Custom duration must be between 1 and 365 days';
      }
    }
    return null;
  }

  static String? validateTrackDays(List<bool> days) {
    if (!days.contains(true)) {
      return 'At least one tracking day must be selected';
    }
    return null;
  }

  int get currentValue =>
      dailyValues.values.fold(0, (sum, value) => sum + value);

  static String toJsonList(List<Tally> tallies) =>
      jsonEncode(tallies.map((t) => t.toJson()).toList());

  static List<Tally> fromJsonList(String json) => (jsonDecode(json) as List)
      .map((item) => Tally.fromJson(item as Map<String, dynamic>))
      .toList();
}
