import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/tally.dart';
import '/providers/tally_provider.dart';
import '/widgets/tally_form.dart';
import 'package:uuid/uuid.dart';
import '/providers/notification_helper.dart';
import '/screens/home_screen.dart';
import '/config/theme_config.dart';
import '/providers/theme_notifier.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        SnackBar(
          content: Text(
            'Please fill in all required fields',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    _formKey.currentState!.save();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final gradientColors = isDarkMode
        ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
        : [const Color(0xFF0064A0), const Color(0xFF004D7A)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ).animate().fadeIn(duration: 300.ms).scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
        title: Text(
          'New Habit',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(
              begin: -0.2,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutQuad,
            ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: TallyForm(
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
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
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
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
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
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientColors[1].withAlpha(77),
                gradientColors[1],
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 51),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.withAlpha(77),
              foregroundColor: Colors.white.withAlpha(204),
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
                    'Create Habit',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(duration: 300.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),
          ),
        ),
      ),
    );
  }
}
