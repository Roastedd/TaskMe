import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/tally.dart';
import '/providers/tally_provider.dart';
import '/widgets/tally_form.dart';
import 'package:uuid/uuid.dart';
import '/providers/notification_helper.dart';
import '/screens/home_screen.dart'; // Import your home screen

class CreateTallyScreen extends StatelessWidget {
  const CreateTallyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TallyFormState> formKey = GlobalKey<TallyFormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
        actions: [
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validateForm()) {
                formKey.currentState!.saveForm();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: TallyForm(
        key: formKey,
        onSave: (formData) async {
          final newTally = Tally(
            id: const Uuid().v4(),
            title: formData['tallyName'],  // Changed from name to title
            incrementValue: formData['incrementValue'],
            targetValue: formData['goalType'] == GoalType.reachAmount ? formData['goal'] : 0,
            setTarget: formData['goalType'] == GoalType.reachAmount,
            color: formData['colorIndex'],
            resetInterval: formData['frequency'],
            trackDays: formData['selectedDays'],
            lastModified: DateTime.now(),
            startDate: formData['startDate'],
            weeklyFrequency: formData['weeklyFrequency'],
            intervalFrequency: formData['intervalFrequency'],
            xp: 0,
            level: 1,
            reminderTimes: formData['reminderTimes'],
            quote: formData['quote'],
            showQuoteInsteadOfTime: formData['showQuoteInsteadOfTime'],
            customDuration: formData['customDuration'],
            durationOption: formData['durationOption'],
            unitType: formData['unitType'],
          );

          Provider.of<TallyProvider>(context, listen: false).addTally(newTally);

          // Schedule notifications
          final notificationHelper = NotificationHelper();
          for (var i = 0; i < formData['reminderTimes'].length; i++) {
            var time = formData['reminderTimes'][i];
            if (time.isAfter(DateTime.now())) {
              await notificationHelper.scheduleNotification(
                newTally.id.hashCode + i,
                'Task Reminder',
                'It\'s time to complete your task: ${newTally.title}!',
                time, // Changed from newTally.name to newTally.title
              );
            }
          }

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigate to your home screen
                  (route) => false,
            );
          }
        },
      ),
    );
  }
}
