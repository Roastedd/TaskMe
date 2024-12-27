import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/tally.dart';
import '/widgets/tally_form.dart';
import '/providers/tally_provider.dart';
import '/providers/notification_helper.dart';
import '/screens/home_screen.dart'; // Import your home screen


class EditTallyScreen extends StatelessWidget {
  final Tally tally;

  const EditTallyScreen({super.key, required this.tally});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TallyFormState> formKey = GlobalKey<TallyFormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
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
        initialData: tally,
        onSave: (formData) async {
          final updatedTally = tally.copyWith(
            title: formData['tallyName'], // Changed from name to title
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
            reminderTimes: formData['reminderTimes'],
            quote: formData['quote'],
            showQuoteInsteadOfTime: formData['showQuoteInsteadOfTime'],
            customDuration: formData['customDuration'],
            durationOption: formData['durationOption'],
            unitType: formData['unitType'],
          );

          Provider.of<TallyProvider>(context, listen: false).updateTally(updatedTally);

          // Schedule notifications
          final notificationHelper = NotificationHelper();
          await notificationHelper.cancelTallyNotifications(tally.id.hashCode);
          for (var i = 0; i < formData['reminderTimes'].length; i++) {
            var time = formData['reminderTimes'][i];
            if (time.isAfter(DateTime.now())) {
              await notificationHelper.scheduleNotification(
                updatedTally.id.hashCode + i,
                'Task Reminder',
                'It\'s time to complete your task: ${updatedTally.title}!',
                time, // Changed from updatedTally.name to updatedTally.title
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
