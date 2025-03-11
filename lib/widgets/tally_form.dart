import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tally.dart';
import '../providers/tally_provider.dart';
import '../config/theme_config.dart';

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
  int _color = Colors.orange.value;

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

  Widget _buildFrequencySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequency',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
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
          ),
          const SizedBox(height: 24),
          Text(
            'Pick Days',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .asMap()
                .entries
                .map((entry) {
              return _buildDayButton(entry.value, entry.key);
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
        backgroundColor: isSelected ? Colors.orange : Colors.grey[800],
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
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
        backgroundColor: isSelected ? Colors.orange : Colors.grey[800],
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colorOptions.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() => _color = color.value);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _color == color.value
                          ? Colors.white
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
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
              ),
              if (title == 'Section')
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    // Handle section add
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Run',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _titleController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildFrequencySelector(),
            const SizedBox(height: 24),
            _buildSection(
              'Goal',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Achieve it all',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Start Date',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mar 10',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Goal Days',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Forever',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Section',
              child: Wrap(
                spacing: 8,
                children: [
                  _buildSectionChip('g', isSelected: true),
                  _buildSectionChip('Afternoon'),
                  _buildSectionChip('Night'),
                  _buildSectionChip('Others', isSelected: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Reminder',
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.orange[400]),
                  const SizedBox(width: 8),
                  Text(
                    'Add',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.orange[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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

  Widget _buildSectionChip(String label, {bool isSelected = false}) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {},
      backgroundColor: Colors.grey[800],
      selectedColor: Colors.orange,
      labelStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}
