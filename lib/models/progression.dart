class Progression {
  final int currentValue;
  final int targetValue;
  final DateTime startDate;
  final DateTime endDate;

  const Progression({
    required this.currentValue,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
  });

  double get progressPercentage =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentValue >= targetValue;

  Duration get remainingTime => endDate.difference(DateTime.now());

  Map<String, dynamic> toJson() => {
        'currentValue': currentValue,
        'targetValue': targetValue,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

  factory Progression.fromJson(Map<String, dynamic> json) => Progression(
        currentValue: json['currentValue'] as int,
        targetValue: json['targetValue'] as int,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
      );
}
