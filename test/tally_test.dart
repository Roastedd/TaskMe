import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskme/providers/user_provider.dart';
import 'package:taskme/providers/tally_provider.dart';
import 'package:taskme/screens/home_screen.dart';
import 'package:taskme/models/tally.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Tally Creation Flow', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
            create: (_) => TallyProvider(UserProvider(), prefs)),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));

    // Verify initial state
    expect(find.text('Create New Habit'), findsOneWidget);

    // Complete form
    await tester.tap(find.text('Create New Habit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Morning Jog');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify creation
    expect(find.text('Morning Jog'), findsOneWidget);
  });

  group('Tally Model Tests', () {
    test('DurationOption serialization', () {
      const option = DurationOption.days30;
      expect(Tally.durationOptionFromString(option.toString().split('.').last),
          DurationOption.days30);
    });

    test('UnitType conversion', () {
      expect(UnitType.minutes.displayName, 'minutes');
      expect(Tally.unitTypeFromString('minutes'), 'minutes');
    });
  });

  group('Tally Provider Tests', () {
    late TallyProvider provider;
    late SharedPreferences prefs;

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
      provider = TallyProvider(MockUserProvider(), prefs);
    });

    test('Add tally validation', () {
      final invalidTally = Tally(
        title: '',
        color: 0xFF000000,
        resetInterval: ResetInterval.daily,
        trackDays: List.filled(7, true),
        incrementValue: 1,
        goalType: GoalType.achieveAll,
        targetValue: 0,
        unitType: UnitType.times,
        durationOption: DurationOption.forever,
      );

      expect(
          () => provider.addTally(invalidTally), throwsA(isA<ArgumentError>()));
    });
  });

  group('Tally', () {
    test('should create a Tally instance with required fields', () {
      final tally = Tally(
        id: '1',
        title: 'Test Tally',
        color: 0xFF49A6A6,
        resetInterval: ResetInterval.daily,
        weeklyFrequency: 1,
        intervalFrequency: 1,
        trackDays: List.filled(7, true),
        startDate: DateTime.now(),
        targetValue: 10,
        incrementValue: 1,
        goalType: GoalType.reachAmount,
        unitType: UnitType.times,
        durationOption: DurationOption.forever,
        reminderTimes: [],
        showQuoteInsteadOfTime: false,
        dailyValues: {},
        lastModified: DateTime.now(),
      );

      expect(tally.id, '1');
      expect(tally.title, 'Test Tally');
      expect(tally.color, 0xFF49A6A6);
      expect(tally.resetInterval, ResetInterval.daily);
      expect(tally.weeklyFrequency, 1);
      expect(tally.intervalFrequency, 1);
      expect(tally.trackDays, List.filled(7, true));
      expect(tally.targetValue, 10);
      expect(tally.incrementValue, 1);
      expect(tally.goalType, GoalType.reachAmount);
      expect(tally.unitType, UnitType.times);
      expect(tally.durationOption, DurationOption.forever);
      expect(tally.reminderTimes, isEmpty);
      expect(tally.showQuoteInsteadOfTime, false);
      expect(tally.dailyValues, isEmpty);
    });

    test('should convert to and from JSON', () {
      final now = DateTime.now();
      final tally = Tally(
        id: '1',
        title: 'Test Tally',
        color: 0xFF49A6A6,
        resetInterval: ResetInterval.daily,
        weeklyFrequency: 1,
        intervalFrequency: 1,
        trackDays: List.filled(7, true),
        startDate: now,
        targetValue: 10,
        incrementValue: 1,
        goalType: GoalType.reachAmount,
        unitType: UnitType.times,
        durationOption: DurationOption.forever,
        reminderTimes: [],
        showQuoteInsteadOfTime: false,
        dailyValues: {},
        lastModified: now,
      );

      final json = tally.toJson();
      final fromJson = Tally.fromJson(json);

      expect(fromJson.id, tally.id);
      expect(fromJson.title, tally.title);
      expect(fromJson.color, tally.color);
      expect(fromJson.resetInterval, tally.resetInterval);
      expect(fromJson.weeklyFrequency, tally.weeklyFrequency);
      expect(fromJson.intervalFrequency, tally.intervalFrequency);
      expect(fromJson.trackDays, tally.trackDays);
      expect(fromJson.targetValue, tally.targetValue);
      expect(fromJson.incrementValue, tally.incrementValue);
      expect(fromJson.goalType, tally.goalType);
      expect(fromJson.unitType, tally.unitType);
      expect(fromJson.durationOption, tally.durationOption);
      expect(fromJson.reminderTimes, tally.reminderTimes);
      expect(fromJson.showQuoteInsteadOfTime, tally.showQuoteInsteadOfTime);
      expect(fromJson.dailyValues, tally.dailyValues);
    });
  });
}

class MockUserProvider extends UserProvider {}
