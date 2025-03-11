import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/tally.dart';
import '/providers/tally_provider.dart';
import '/widgets/tally_form.dart';
import 'package:uuid/uuid.dart';
import '/providers/notification_helper.dart';
import '/screens/home_screen.dart'; // Import your home screen
import '/config/theme_config.dart';

class CreateTallyScreen extends StatefulWidget {
  const CreateTallyScreen({super.key});

  @override
  State<CreateTallyScreen> createState() => _CreateTallyScreenState();
}

class _CreateTallyScreenState extends State<CreateTallyScreen> {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'New Habit',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: TallyForm(
        key: _formKey,
        onSave: (formData) async {
          try {
            final newTally = Tally(
              id: const Uuid().v4(),
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
              xp: 0,
              level: 1,
              reminderTimes: formData.reminderTimes,
              quote: formData.quote,
              showQuoteInsteadOfTime: formData.showQuoteInsteadOfTime,
              customDuration: formData.customDuration,
              durationOption: formData.durationOption,
              unitType: formData.unitType,
              goalType: formData.goalType,
            );

            await Provider.of<TallyProvider>(context, listen: false)
                .addTally(newTally);

            // Schedule notifications
            final notificationHelper = NotificationHelper();
            for (var i = 0; i < formData.reminderTimes.length; i++) {
              var time = formData.reminderTimes[i];
              if (time.isAfter(DateTime.now())) {
                await notificationHelper.scheduleNotification(
                  newTally.id.hashCode + i,
                  'Task Reminder',
                  'It\'s time to complete your task: ${newTally.title}!',
                  time,
                );
              }
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Habit created successfully!',
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
                    'Error creating habit: ${e.toString()}',
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        ),
      ),
    );
  }
}
