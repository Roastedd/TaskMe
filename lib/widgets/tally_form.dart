import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../models/tally.dart';
import '../providers/tally_provider.dart';

class TallyForm extends StatefulWidget {
  final Tally? initialData;
  final void Function(Tally tally)? onSave;

  const TallyForm({super.key, this.initialData, this.onSave});

  @override
  State<TallyForm> createState() => _TallyFormState();
}

class _TallyFormState extends State<TallyForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _incrementController = TextEditingController();
  bool _isLoading = false;
  bool _hasTarget = false;
  ResetInterval _resetInterval = ResetInterval.daily;
  List<bool> _trackDays = List.filled(7, true);
  GoalType _goalType = GoalType.achieveAll;
  UnitType _unitType = UnitType.times;
  DurationOption _durationOption = DurationOption.days30;
  int _weeklyFrequency = 1;
  int _intervalFrequency = 1;
  List<DateTime> _reminderTimes = [];
  String? _quote;
  bool _showQuoteInsteadOfTime = false;
  int? _customDuration;
  int _color = Colors.orange.toARGB32();

  final List<Color> _colorOptions = [
    Colors.orange,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!.title;
      _targetController.text = widget.initialData!.targetValue.toString();
      _incrementController.text = widget.initialData!.incrementValue.toString();
      _hasTarget = widget.initialData!.setTarget;
      _resetInterval = widget.initialData!.resetInterval;
      _trackDays = widget.initialData!.trackDays;
      _goalType = widget.initialData!.goalType;
      _unitType = widget.initialData!.unitType;
      _durationOption = widget.initialData!.durationOption;
      _weeklyFrequency = widget.initialData!.weeklyFrequency;
      _intervalFrequency = widget.initialData!.intervalFrequency;
      _reminderTimes = widget.initialData!.reminderTimes;
      _quote = widget.initialData!.quote;
      _showQuoteInsteadOfTime = widget.initialData!.showQuoteInsteadOfTime;
      _customDuration = widget.initialData!.customDuration;
      _color = widget.initialData!.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _incrementController.dispose();
    super.dispose();
  }

  Future<void> _saveTally() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tally = Tally(
        id: widget.initialData?.id ?? '',
        title: _titleController.text.trim(),
        setTarget: _hasTarget,
        targetValue: _hasTarget ? int.parse(_targetController.text) : 0,
        lastModified: DateTime.now(),
        startDate: DateTime.now(),
        dailyValues: widget.initialData?.dailyValues ?? {},
        showQuoteInsteadOfTime: _showQuoteInsteadOfTime,
        quote: _quote,
        color: _color,
        resetInterval: _resetInterval,
        trackDays: _trackDays,
        incrementValue: int.parse(_incrementController.text),
        goalType: _goalType,
        unitType: _unitType,
        durationOption: _durationOption,
        weeklyFrequency: _weeklyFrequency,
        intervalFrequency: _intervalFrequency,
        reminderTimes: _reminderTimes,
        customDuration: _customDuration,
      );

      if (widget.onSave != null) {
        widget.onSave!(tally);
      } else {
        await Provider.of<TallyProvider>(context, listen: false)
            .addTally(tally);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving tally: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSection(String title,
      {required Widget child, bool showAddButton = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(26),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(
                          begin: -0.2,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutQuad,
                        ),
                    if (showAddButton)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.orange),
                        onPressed: () {
                          // Handle section add
                        },
                      ).animate().fadeIn(duration: 400.ms).scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1, 1),
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return _buildSection(
      'Frequency',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFrequencyButton('Daily', ResetInterval.daily),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFrequencyButton('Weekly', ResetInterval.weekly),
              ),
              const SizedBox(width: 8),
              Expanded(
                child:
                    _buildFrequencyButton('Interval', ResetInterval.interval),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(
                begin: 0.2,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutQuad,
              ),
          const SizedBox(height: 24),
          Text(
            'Pick Days',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .asMap()
                .entries
                .map((entry) {
              return _buildDayButton(entry.value, entry.key)
                  .animate(delay: (50 * entry.key).ms)
                  .fadeIn()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyButton(String label, ResetInterval interval) {
    final isSelected = _resetInterval == interval;
    return ElevatedButton(
      onPressed: () {
        setState(() => _resetInterval = interval);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.orange : Colors.black.withAlpha(77),
        foregroundColor: Colors.white,
        elevation: isSelected ? 4 : 0,
        shadowColor:
            isSelected ? Colors.orange.withAlpha(77) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isSelected ? Colors.orange : Colors.white.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildDayButton(String label, int index) {
    final isSelected = _trackDays[index];
    return ElevatedButton(
      onPressed: () {
        setState(() => _trackDays[index] = !_trackDays[index]);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.orange : Colors.black.withAlpha(77),
        foregroundColor: Colors.white,
        elevation: isSelected ? 4 : 0,
        shadowColor:
            isSelected ? Colors.orange.withAlpha(77) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isSelected ? Colors.orange : Colors.white.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return _buildSection(
      'Color',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _colorOptions.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () {
              setState(() => _color = entry.value.toARGB32());
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _color == entry.value.toARGB32()
                      ? Colors.white.withAlpha(204)
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: entry.value.withAlpha(191),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ).animate(delay: (50 * entry.key).ms).fadeIn().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionChip(String label, {bool isSelected = false}) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {},
      backgroundColor: Colors.black.withAlpha(77),
      selectedColor: Colors.orange,
      labelStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.white.withAlpha(26),
          width: 1,
        ),
      ),
      elevation: isSelected ? 4 : 0,
      shadowColor:
          isSelected ? Colors.orange.withAlpha(77) : Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: 'Enter habit name',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white.withAlpha(128),
                  fontSize: 18,
                ),
                filled: true,
                fillColor: Colors.black.withAlpha(77),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withAlpha(26),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withAlpha(26),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _titleController.clear(),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(
                  begin: -0.2,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutQuad,
                ),
            const SizedBox(height: 24),
            _buildFrequencySelector(),
            _buildSection(
              'Goal',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Achieve it all',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.orange),
                ],
              ),
            ),
            _buildSection(
              'Start Date',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Today',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.orange),
                ],
              ),
            ),
            _buildSection(
              'Goal Days',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Forever',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.orange),
                ],
              ),
            ),
            _buildSection(
              'Section',
              showAddButton: true,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSectionChip('Morning', isSelected: true),
                  _buildSectionChip('Afternoon'),
                  _buildSectionChip('Night'),
                  _buildSectionChip('Others', isSelected: true),
                ].asMap().entries.map((entry) {
                  return entry.value
                      .animate(delay: (50 * entry.key).ms)
                      .fadeIn()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      );
                }).toList(),
              ),
            ),
            _buildSection(
              'Reminder',
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.orange.withAlpha(77)),
                  const SizedBox(width: 8),
                  Text(
                    'Add Reminder',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.orange.withAlpha(128),
                    ),
                  ),
                ],
              ),
            ),
            _buildColorPicker(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTally,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Habit'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
