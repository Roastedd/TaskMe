import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  int _color = Colors.blue.value;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!.title;
      _incrementController.text = widget.initialData!.incrementValue.toString();
      if (widget.initialData!.setTarget) {
        _hasTarget = true;
        _targetController.text = widget.initialData!.targetValue.toString();
      }
      _resetInterval = widget.initialData!.resetInterval;
      _trackDays = List.from(widget.initialData!.trackDays);
      _goalType = widget.initialData!.goalType;
      _unitType = widget.initialData!.unitType;
      _durationOption = widget.initialData!.durationOption;
      _weeklyFrequency = widget.initialData!.weeklyFrequency;
      _intervalFrequency = widget.initialData!.intervalFrequency;
      _reminderTimes = List.from(widget.initialData!.reminderTimes);
      _quote = widget.initialData!.quote;
      _showQuoteInsteadOfTime = widget.initialData!.showQuoteInsteadOfTime;
      _customDuration = widget.initialData!.customDuration;
      _color = widget.initialData?.color ?? Colors.blue.value;
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter tally title',
              ),
              validator: Tally.validateTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _incrementController,
              decoration: const InputDecoration(
                labelText: 'Increment Value',
                hintText: 'Enter increment value (1-100)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  Tally.validateIncrementValue(int.tryParse(value ?? '')),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set Target'),
              value: _hasTarget,
              onChanged: (value) {
                setState(() => _hasTarget = value);
              },
            ),
            if (_hasTarget) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Target Value',
                  hintText: 'Enter target number',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    Tally.validateTargetValue(int.tryParse(value ?? '')),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<ResetInterval>(
              value: _resetInterval,
              decoration: const InputDecoration(
                labelText: 'Reset Interval',
              ),
              items: ResetInterval.values.map((interval) {
                return DropdownMenuItem(
                  value: interval,
                  child: Text(interval.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _resetInterval = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GoalType>(
              value: _goalType,
              decoration: const InputDecoration(
                labelText: 'Goal Type',
              ),
              items: GoalType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _goalType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UnitType>(
              value: _unitType,
              decoration: const InputDecoration(
                labelText: 'Unit Type',
              ),
              items: UnitType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _unitType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DurationOption>(
              value: _durationOption,
              decoration: const InputDecoration(
                labelText: 'Duration Option',
              ),
              items: DurationOption.values.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _durationOption = value);
                }
              },
            ),
            if (_durationOption == DurationOption.custom) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _customDuration?.toString(),
                decoration: const InputDecoration(
                  labelText: 'Custom Duration (days)',
                  hintText: 'Enter number of days',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => Tally.validateCustomDuration(
                  _durationOption,
                  int.tryParse(value ?? ''),
                ),
                onChanged: (value) {
                  setState(() => _customDuration = int.tryParse(value));
                },
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTally,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
