// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskme/models/tally.dart';
import 'package:taskme/providers/tally_provider.dart';
import 'package:taskme/screens/create_tally_screen.dart';
import 'package:taskme/screens/home_screen.dart';
import 'package:taskme/widgets/tally_form.dart';
import 'package:taskme/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserProvider extends UserProvider {
  MockUserProvider() : super(); // Call super constructor with no arguments
}

class MockTallyProvider extends TallyProvider {
  Tally? addedTally;

  MockTallyProvider() : super(MockUserProvider(), SharedPreferences.setMockInitialValues({}) as SharedPreferences);

  @override
  Future<void> addTally(Tally tally) async {
    addedTally = tally;
  }
}

void main() {
  testWidgets('CreateTallyScreen test', (WidgetTester tester) async {
    final mockTallyProvider = MockTallyProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<TallyProvider>.value(
        value: mockTallyProvider,
        child: const MaterialApp(
          home: CreateTallyScreen(),
        ),
      ),
    );

    // Find the TallyForm
    final tallyFormFinder = find.byType(TallyForm);
    expect(tallyFormFinder, findsOneWidget);

    // Enter Tally Name
    await tester.enterText(find.byType(TextFormField).first, 'My New Tally');

    // Select Frequency (Daily) - default, no action needed

    // Set Increment Value
    await tester.enterText(find.byType(TextFormField).at(1), '2');

    // Tap the Goal card
    await tester.tap(find.textContaining('Count / Daily'));
    await tester.pumpAndSettle();

    // Set Goal to Reach a certain amount (default), set value to 100, unit type to Cup
    await tester.enterText(find.byType(TextFormField).at(2), '100'); // Goal amount
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cup').last); // Select "Cup"
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').first);
    await tester.pumpAndSettle();

    // Set Start Date (default is today, no action needed)

    // Set Goal Days (default is Forever, no action needed)

    // Add a reminder
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // Select current time
    await tester.pumpAndSettle();

    // Enter Quote
    await tester.enterText(find.byType(TextFormField).at(2), 'My test quote');

    // Set Display Option (default is Show Last Modified Time, no action needed)

    // Choose a Color (default is first, no action needed)

    // Tap the Save button in the AppBar
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify that addTally was called with the correct arguments
    expect(mockTallyProvider.addedTally, isNotNull);
    expect(mockTallyProvider.addedTally!.title, 'My New Tally');
    expect(mockTallyProvider.addedTally!.incrementValue, 2);
    expect(mockTallyProvider.addedTally!.targetValue, 100);
    expect(mockTallyProvider.addedTally!.unitType, 'Cup');
    expect(mockTallyProvider.addedTally!.reminderTimes, isNotEmpty);
    expect(mockTallyProvider.addedTally!.quote, 'My test quote');

    // Verify navigation to HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
