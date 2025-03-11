import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/tally.dart';
import '/providers/tally_provider.dart';
import '/widgets/tally_form.dart';
import '/providers/notification_helper.dart';
import '/screens/home_screen.dart';
import '/config/theme_config.dart';

class EditTallyScreen extends StatefulWidget {
  final Tally tally;

  const EditTallyScreen({super.key, required this.tally});

  @override
  State<EditTallyScreen> createState() => _EditTallyScreenState();
}

class _EditTallyScreenState extends State<EditTallyScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _saveForm() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);
    _formKey.currentState!.save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Habit',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveForm,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: TallyForm(
        key: _formKey,
        initialData: widget.tally,
        onSave: (formData) async {
          try {
            final updatedTally = widget.tally.copyWith(
              title: formData.title,
              incrementValue: formData.incrementValue,
              targetValue: formData.goalType == GoalType.reachAmount
                  ? formData.targetValue
                  : 0,
              setTarget: formData.goalType == GoalType.reachAmount,
              color: formData.color,
              resetInterval: formData.resetInterval,
              trackDays: formData.trackDays,
              lastModified: DateTime.now(),
              startDate: formData.startDate,
              weeklyFrequency: formData.weeklyFrequency,
              intervalFrequency: formData.intervalFrequency,
              reminderTimes: formData.reminderTimes,
              quote: formData.quote,
              showQuoteInsteadOfTime: formData.showQuoteInsteadOfTime,
              customDuration: formData.customDuration,
              durationOption: formData.durationOption,
              unitType: formData.unitType,
            );

            await Provider.of<TallyProvider>(context, listen: false)
                .updateTally(updatedTally);

            // Schedule notifications
            final notificationHelper = NotificationHelper();
            await notificationHelper
                .cancelTallyNotifications(widget.tally.id.hashCode);
            for (var i = 0; i < formData.reminderTimes.length; i++) {
              var time = formData.reminderTimes[i];
              if (time.isAfter(DateTime.now())) {
                await notificationHelper.scheduleNotification(
                  updatedTally.id.hashCode + i,
                  'Task Reminder',
                  'It\'s time to complete your task: ${updatedTally.title}!',
                  time,
                );
              }
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Habit updated successfully!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error updating habit: ${e.toString()}',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() => _isSaving = false);
            }
          }
        },
      ),
    );
  }
}
