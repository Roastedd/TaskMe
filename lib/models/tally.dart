import 'dart:convert';

enum GoalType { achieveAll, reachAmount }
// Define the DurationOption enum
enum DurationOption { forever, days7, days21, days30, days100, days365, custom }

class Tally {
  final String id;
  final String title; // Renamed from `name`
  Map<String, int> dailyValues;
  final int incrementValue;
  final int targetValue;
  final bool setTarget;
  final int color;
  final String resetInterval;
  final List<bool> trackDays;
  DateTime lastResetDate;
  DateTime lastModified;
  int xp;
  int level;
  final int weeklyFrequency;
  final DateTime startDate;
  final int intervalFrequency;
  List<DateTime>? reminderTimes;
  final String quote;
  final bool showQuoteInsteadOfTime;
  final DurationOption durationOption;
  final int customDuration;
  final String unitType;

  Tally({
    required this.id,
    required this.title, // Updated property name
    Map<String, int>? dailyValues,
    required this.incrementValue,
    required this.targetValue,
    required this.setTarget,
    required this.color,
    required this.resetInterval,
    required this.trackDays,
    DateTime? lastResetDate,
    DateTime? lastModified,
    this.xp = 0,
    this.level = 1,
    this.weeklyFrequency = 7,
    DateTime? startDate,
    this.intervalFrequency = 1,
    this.reminderTimes,
    this.quote = "Keep pushing forward!",
    this.showQuoteInsteadOfTime = false,
    this.durationOption = DurationOption.forever,
    this.customDuration = 7,
    this.unitType = 'Count',
  })  : dailyValues = dailyValues ?? {},
        lastResetDate = lastResetDate ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now(),
        startDate = startDate ?? DateTime.now();

  Tally copyWith({
    String? id,
    String? title, // Updated property name
    Map<String, int>? dailyValues,
    int? incrementValue,
    int? targetValue,
    bool? setTarget,
    int? color,
    String? resetInterval,
    List<bool>? trackDays,
    DateTime? lastResetDate,
    DateTime? lastModified,
    int? xp,
    int? level,
    int? weeklyFrequency,
    DateTime? startDate,
    int? intervalFrequency,
    List<DateTime>? reminderTimes,
    String? quote,
    bool? showQuoteInsteadOfTime,
    DurationOption? durationOption,
    int? customDuration,
    String? unitType,
  }) {
    return Tally(
      id: id ?? this.id,
      title: title ?? this.title, // Updated property name
      dailyValues: dailyValues ?? this.dailyValues,
      incrementValue: incrementValue ?? this.incrementValue,
      targetValue: targetValue ?? this.targetValue,
      setTarget: setTarget ?? this.setTarget,
      color: color ?? this.color,
      resetInterval: resetInterval ?? this.resetInterval,
      trackDays: trackDays ?? this.trackDays,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      lastModified: lastModified ?? this.lastModified,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      startDate: startDate ?? this.startDate,
      intervalFrequency: intervalFrequency ?? this.intervalFrequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      quote: quote ?? this.quote,
      showQuoteInsteadOfTime: showQuoteInsteadOfTime ?? this.showQuoteInsteadOfTime,
      durationOption: durationOption ?? this.durationOption,
      customDuration: customDuration ?? this.customDuration,
      unitType: unitType ?? this.unitType,
    );
  }

  factory Tally.fromJson(String source) => Tally.fromMap(json.decode(source));

  factory Tally.fromMap(Map<String, dynamic> map) {
    try {
      return Tally(
        id: map['id'] ?? '',
        title: map['title'] ?? 'Untitled', // Provide default for missing title
        dailyValues: map['dailyValues'] != null 
            ? Map<String, int>.from(map['dailyValues']) 
            : <String, int>{},
        incrementValue: map['incrementValue'] ?? 1,
        targetValue: map['targetValue'] ?? 0,
        setTarget: map['setTarget'] ?? false,
        color: map['color'] ?? 0xFF0064A0, // Default blue color
        resetInterval: map['resetInterval'] ?? '',
        trackDays: map['trackDays'] != null 
            ? List<bool>.from(map['trackDays']) 
            : List.filled(7, true), // Default to all days
        lastResetDate: map['lastResetDate'] != null 
            ? DateTime.parse(map['lastResetDate']) 
            : DateTime.now(),
        lastModified: map['lastModified'] != null 
            ? DateTime.parse(map['lastModified']) 
            : DateTime.now(),
        xp: map['xp'] ?? 0,
        level: map['level'] ?? 1,
        weeklyFrequency: map['weeklyFrequency'] ?? 7,
        startDate: map['startDate'] != null 
            ? DateTime.parse(map['startDate']) 
            : DateTime.now(),
        intervalFrequency: map['intervalFrequency'] ?? 1,
        reminderTimes: (map['reminderTimes'] as List<dynamic>?)
            ?.map((e) => DateTime.parse(e as String))
            .toList(),
        quote: map['quote'] ?? "Keep pushing forward!",
        showQuoteInsteadOfTime: map['showQuoteInsteadOfTime'] ?? false,
        durationOption: _parseDurationOption(map['durationOption']),
        customDuration: map['customDuration'] ?? 7,
        unitType: map['unitType'] ?? 'Count',
      );
    } catch (e) {
      print('Error parsing Tally: $e');
      // Return a default Tally object if parsing fails
      return Tally(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Error Tally',
        incrementValue: 1,
        targetValue: 0,
        setTarget: false,
        color: 0xFF0064A0,
        resetInterval: '',
        trackDays: List.filled(7, true),
      );
    }
  }

  // Helper method to safely parse DurationOption
  static DurationOption _parseDurationOption(dynamic value) {
    if (value == null) return DurationOption.forever;
    
    try {
      if (value is String && value.startsWith('DurationOption.')) {
        final enumString = value.split('.').last;
        return DurationOption.values.firstWhere(
          (e) => e.toString() == 'DurationOption.$enumString',
          orElse: () => DurationOption.forever,
        );
      } else if (value is String) {
        return DurationOption.values.firstWhere(
          (e) => e.toString() == 'DurationOption.$value',
          orElse: () => DurationOption.forever,
        );
      }
    } catch (e) {
      print('Error parsing DurationOption: $e');
    }
    
    return DurationOption.forever;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title, // Updated property name
      'dailyValues': dailyValues,
      'incrementValue': incrementValue,
      'targetValue': targetValue,
      'setTarget': setTarget,
      'color': color,
      'resetInterval': resetInterval,
      'trackDays': trackDays,
      'lastResetDate': lastResetDate.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'xp': xp,
      'level': level,
      'weeklyFrequency': weeklyFrequency,
      'startDate': startDate.toIso8601String(),
      'intervalFrequency': intervalFrequency,
      'reminderTimes': reminderTimes?.map((e) => e.toIso8601String()).toList(),
      'quote': quote,
      'showQuoteInsteadOfTime': showQuoteInsteadOfTime,
      'durationOption': durationOption.toString().split('.').last,
      'customDuration': customDuration,
      'unitType': unitType,
    };
  }

  String toJson() => json.encode(toMap());

  bool shouldShowOn(DateTime date) {
    if (date.isBefore(startDate)) {
      return false;
    }

    if (resetInterval == 'Daily') {
      return trackDays[date.weekday % 7];
    } else if (resetInterval == 'Weekly') {
      int daysSinceStart = date.difference(startDate).inDays;
      return (daysSinceStart % 7) < weeklyFrequency;
    } else if (resetInterval == 'Interval') {
      int daysSinceStart = date.difference(startDate).inDays;
      return daysSinceStart % intervalFrequency == 0;
    }
    return false;
  }
}
