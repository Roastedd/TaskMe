class Statistics {
  final int totalCount;
  final int dailyAverage;
  final int weeklyAverage;
  final int monthlyAverage;
  final int bestStreak;
  final int currentStreak;
  final Map<String, int> dailyValues;

  const Statistics({
    required this.totalCount,
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.bestStreak,
    required this.currentStreak,
    required this.dailyValues,
  });

  Map<String, dynamic> toJson() => {
        'totalCount': totalCount,
        'dailyAverage': dailyAverage,
        'weeklyAverage': weeklyAverage,
        'monthlyAverage': monthlyAverage,
        'bestStreak': bestStreak,
        'currentStreak': currentStreak,
        'dailyValues': dailyValues,
      };

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
        totalCount: json['totalCount'] as int,
        dailyAverage: json['dailyAverage'] as int,
        weeklyAverage: json['weeklyAverage'] as int,
        monthlyAverage: json['monthlyAverage'] as int,
        bestStreak: json['bestStreak'] as int,
        currentStreak: json['currentStreak'] as int,
        dailyValues: Map<String, int>.from(json['dailyValues'] as Map),
      );

  Statistics copyWith({
    int? totalCount,
    int? dailyAverage,
    int? weeklyAverage,
    int? monthlyAverage,
    int? bestStreak,
    int? currentStreak,
    Map<String, int>? dailyValues,
  }) =>
      Statistics(
        totalCount: totalCount ?? this.totalCount,
        dailyAverage: dailyAverage ?? this.dailyAverage,
        weeklyAverage: weeklyAverage ?? this.weeklyAverage,
        monthlyAverage: monthlyAverage ?? this.monthlyAverage,
        bestStreak: bestStreak ?? this.bestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
        dailyValues: dailyValues ?? this.dailyValues,
      );
}
