import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/widgets/color_chip.dart';
import '/providers/theme_notifier.dart';
import 'package:numberpicker/numberpicker.dart';
import '/widgets/custom_time_picker.dart';
import '/models/tally.dart';


class TallyForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Tally? initialData;

  const TallyForm({super.key, required this.onSave, this.initialData});

  @override
  TallyFormState createState() => TallyFormState();
}

class TallyFormState extends State<TallyForm> {
  final _formKey = GlobalKey<FormState>();
  late String _tallyName;
  late String _frequency;
  late int _weeklyFrequency;
  late int _intervalFrequency;
  final List<String> _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  late List<bool> _selectedDays;
  late DateTime _startDate;
  late int _goal;
  late String _quote;
  late int _colorIndex;
  late int _incrementValue;
  GoalType? _goalType;
  late String _unitType;
  late DurationOption _durationOption;
  late int _customDuration;
  final List<DateTime> _reminderTimes = [];
  late bool _showQuoteInsteadOfTime;

  final List<Color> _colors = [
    const Color(0xFF49A6A6),
    const Color(0xFF5FC25F),
    const Color(0xFFF08080),
    const Color(0xFFFFD700),
    const Color(0xFFBA55D3),
    const Color(0xFF6958E7),
    const Color(0xFFD2B48C),
    const Color(0xFF53C486),
    const Color(0xFFB98F59),
    const Color(0xFF4682B4),
    const Color(0xFFFF6347),
    const Color(0xFF604EC0),
    const Color(0xFFBDB76B),
    const Color(0xFFBB693B),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _tallyName = widget.initialData!.title; // Changed from name to title
      _frequency = widget.initialData!.resetInterval;
      _weeklyFrequency = widget.initialData!.weeklyFrequency;
      _intervalFrequency = widget.initialData!.intervalFrequency;
      _selectedDays = List.from(widget.initialData!.trackDays);
      _startDate = widget.initialData!.startDate;
      _goal = widget.initialData!.targetValue;
      _quote = widget.initialData!.quote;
      _colorIndex = _colors.indexWhere((color) => color.value == widget.initialData!.color);
      _incrementValue = widget.initialData!.incrementValue;
      _goalType = widget.initialData!.setTarget ? GoalType.reachAmount : GoalType.achieveAll;
      _unitType = widget.initialData!.unitType;
      _durationOption = widget.initialData!.durationOption;
      _customDuration = widget.initialData!.customDuration;
      _reminderTimes.addAll(widget.initialData!.reminderTimes ?? []);
      _showQuoteInsteadOfTime = widget.initialData!.showQuoteInsteadOfTime;
    } else {
      _tallyName = '';
      _frequency = 'Daily';
      _weeklyFrequency = 1;
      _intervalFrequency = 2;
      _selectedDays = List.filled(7, true);
      _startDate = DateTime.now();
      _goal = 50;
      _quote = "Try a little harder to be a little better";
      _colorIndex = 0;
      _incrementValue = 1;
      _goalType = GoalType.reachAmount;
      _unitType = 'Count';
      _durationOption = DurationOption.forever;
      _customDuration = 7;
      _showQuoteInsteadOfTime = false;
    }
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void saveForm() {
    _formKey.currentState?.save();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final cardColor = isDarkMode ? Colors.grey[850]! : const Color(0xFF0088CC);
    final buttonColor = isDarkMode ? Colors.grey[800]! : const Color(0xFF00A8E8);
    const textColor = Colors.white;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCard(
            color: cardColor,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.fitness_center, color: Colors.white),
              ),
              title: TextFormField(
                initialValue: _tallyName,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: TextStyle(color: textColor),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: textColor),
                onChanged: (value) {
                  _tallyName = value;
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Frequency', style: TextStyle(color: textColor)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Daily', 'Weekly', 'Interval'].map((freq) {
                      return ChoiceChip(
                        label: Text(freq, style: const TextStyle(color: textColor)),
                        selected: _frequency == freq,
                        selectedColor: Colors.orange,
                        backgroundColor: buttonColor,
                        onSelected: (selected) {
                          setState(() {
                            _frequency = freq;
                            if (freq == 'Daily') {
                              _selectedDays = List.filled(7, true);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (_frequency == 'Weekly') _buildWeeklyFrequencyPicker(),
                  if (_frequency == 'Interval') _buildIntervalFrequencyPicker(),
                  if (_frequency == 'Daily') _buildDailyPicker(buttonColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: ListTile(
              title: const Text('Increment Value', style: TextStyle(color: textColor)),
              subtitle: TextFormField(
                initialValue: '$_incrementValue',
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter increment value',
                  hintStyle: TextStyle(color: textColor),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: textColor),
                onChanged: (value) {
                  _incrementValue = int.parse(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: ListTile(
              title: const Text('Goal', style: TextStyle(color: textColor)),
              subtitle: Text(
                _goalType == GoalType.reachAmount ? '$_goal $_unitType / Daily' : 'No Target',
                style: const TextStyle(color: textColor),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: _showGoalDialog,
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: ListTile(
              title: const Text('Start Date', style: TextStyle(color: textColor)),
              subtitle: Text(DateFormat.yMMMd().format(_startDate), style: const TextStyle(color: textColor)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null && mounted) {
                  setState(() {
                    _startDate = selectedDate;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: ListTile(
              title: const Text('Goal Days', style: TextStyle(color: textColor)),
              subtitle: Text(
                _durationOption == DurationOption.custom
                    ? '$_customDuration Days'
                    : '${_durationOption.toString().split('.').last.replaceAll('days', '')} Days',
                style: const TextStyle(color: textColor),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return _buildGoalDaysDialog(cardColor);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Reminders', style: TextStyle(color: textColor)),
                  trailing: const Icon(Icons.add, color: Colors.orange),
                  onTap: () async {
                    final time = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomTimePicker(initialTime: TimeOfDay.now());
                      },
                    );
                    if (time != null && mounted) {
                      setState(() {
                        final now = DateTime.now();
                        final reminderTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                        _reminderTimes.add(reminderTime);
                      });
                    }
                  },
                ),
                ..._reminderTimes.map((time) {
                  return ListTile(
                    title: Text(
                      'Reminder set for: ${DateFormat.jm().format(time)}',
                      style: const TextStyle(color: textColor),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () async {
                        final newTime = await showDialog<TimeOfDay>(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomTimePicker(initialTime: TimeOfDay.fromDateTime(time));
                          },
                        );
                        if (newTime != null && mounted) {
                          setState(() {
                            if (newTime.hour == -1) {
                              _reminderTimes.remove(time);
                            } else {
                              final now = DateTime.now();
                              final reminderTime = DateTime(now.year, now.month, now.day, newTime.hour, newTime.minute);
                              final index = _reminderTimes.indexOf(time);
                              _reminderTimes[index] = reminderTime;
                            }
                          });
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: ListTile(
              title: const Text('Quote', style: TextStyle(color: textColor)),
              subtitle: TextFormField(
                initialValue: _quote,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter an encouraging quote',
                  hintStyle: TextStyle(color: textColor),
                ),
                style: const TextStyle(color: textColor),
                onChanged: (value) {
                  _quote = value;
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: ListTile(
              title: const Text('Display Option', style: TextStyle(color: textColor)),
              subtitle: Column(
                children: [
                  RadioListTile<bool>(
                    title: const Text('Show Last Modified Time', style: TextStyle(color: textColor)),
                    value: false,
                    groupValue: _showQuoteInsteadOfTime,
                    onChanged: (bool? value) {
                      setState(() {
                        _showQuoteInsteadOfTime = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('Show Quote', style: TextStyle(color: textColor)),
                    value: true,
                    groupValue: _showQuoteInsteadOfTime,
                    onChanged: (bool? value) {
                      setState(() {
                        _showQuoteInsteadOfTime = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildCard(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose a Color', style: TextStyle(color: textColor)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: List.generate(_colors.length, (index) {
                      return ColorChip(
                        color: _colors[index],
                        isSelected: _colorIndex == index,
                        onTap: () {
                          setState(() {
                            _colorIndex = index;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSave({
                  'tallyName': _tallyName,
                  'frequency': _frequency,
                  'weeklyFrequency': _weeklyFrequency,
                  'intervalFrequency': _intervalFrequency,
                  'selectedDays': _selectedDays,
                  'startDate': _startDate,
                  'goal': _goal,
                  'quote': _quote,
                  'colorIndex': _colors[_colorIndex].value,
                  'incrementValue': _incrementValue,
                  'goalType': _goalType,
                  'unitType': _unitType,
                  'durationOption': _durationOption,
                  'customDuration': _customDuration,
                  'reminderTimes': _reminderTimes,
                  'showQuoteInsteadOfTime': _showQuoteInsteadOfTime,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Save', style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Color color, required Widget child}) {
    return Card(
      color: color,
      child: child,
    );
  }

  Widget _buildWeeklyFrequencyPicker() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberPicker(
              value: _weeklyFrequency,
              minValue: 1,
              maxValue: 7,
              onChanged: (value) => setState(() => _weeklyFrequency = value),
              selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
              textStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(width: 10),
            const Text('days per week', style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildIntervalFrequencyPicker() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Every', style: TextStyle(color: Colors.white)),
            NumberPicker(
              value: _intervalFrequency,
              minValue: 2,
              maxValue: 30,
              selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
              textStyle: const TextStyle(color: Colors.grey, fontSize: 18),
              onChanged: (value) => setState(() => _intervalFrequency = value),
            ),
            const Text('days', style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyPicker(Color buttonColor) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text('Pick Days', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: List.generate(_days.length, (index) {
            return ChoiceChip(
              label: Text(_days[index], style: const TextStyle(color: Colors.white)),
              selected: _selectedDays[index],
              selectedColor: Colors.orange,
              backgroundColor: buttonColor,
              onSelected: (selected) {
                setState(() {
                  _selectedDays[index] = selected;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  AlertDialog _buildGoalDaysDialog(Color cardColor) {
    return AlertDialog(
      backgroundColor: cardColor,
      title: const Text('Goal Days', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Forever', style: TextStyle(color: Colors.white)),
              leading: Radio<DurationOption>(
                value: DurationOption.forever,
                groupValue: _durationOption,
                onChanged: (DurationOption? value) {
                  setState(() {
                    _durationOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('7 Days', style: TextStyle(color: Colors.white)),
              leading: Radio<DurationOption>(
                value: DurationOption.days7,
                groupValue: _durationOption,
                onChanged: (DurationOption? value) {
                  setState(() {
                    _durationOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('21 Days', style: TextStyle(color: Colors.white)),
              leading: Radio<DurationOption>(
                value: DurationOption.days21,
                groupValue: _durationOption,
                onChanged: (DurationOption? value) {
                  setState(() {
                    _durationOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('30 Days', style: TextStyle(color: Colors.white)),
              leading: Radio<DurationOption>(
                value: DurationOption.days30,
                groupValue: _durationOption,
                onChanged: (DurationOption? value) {
                  setState(() {
                    _durationOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('100 Days', style: TextStyle(color: Colors.white)),
              leading: Radio<DurationOption>(
                value: DurationOption.days100,
                groupValue: _durationOption,
                onChanged: (DurationOption? value) {
                  setState(() {
                    _durationOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('365 Days', style: TextStyle(color: Colors.white)),
              leading: Radio<DurationOption>(
                value: DurationOption.days365,
                groupValue: _durationOption,
                onChanged: (DurationOption? value) {
                  setState(() {
                    _durationOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  const Text('Custom', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: '$_customDuration',
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          _customDuration = int.parse(value);
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Days',
                        hintStyle: TextStyle(color: Colors.white),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              leading: Radio<DurationOption>(
                value: DurationOption.custom,
                groupValue: _durationOption,
                onChanged: (DurationOption? value) {
                  setState(() {
                    _durationOption = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Done', style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Provider.of<ThemeNotifier>(context).isDarkMode
                  ? Colors.grey[850]!
                  : const Color(0xFF0088CC),
              title: const Text('Goal', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Achieve it all', style: TextStyle(color: Colors.white)),
                    leading: Radio<GoalType>(
                      value: GoalType.achieveAll,
                      groupValue: _goalType,
                      onChanged: (GoalType? value) {
                        setDialogState(() {
                          _goalType = value;
                        });
                        setState(() {
                          _goalType = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Reach a certain amount', style: TextStyle(color: Colors.white)),
                    leading: Radio<GoalType>(
                      value: GoalType.reachAmount,
                      groupValue: _goalType,
                      onChanged: (GoalType? value) {
                        setDialogState(() {
                          _goalType = value;
                        });
                        setState(() {
                          _goalType = value;
                        });
                      },
                    ),
                  ),
                  if (_goalType == GoalType.reachAmount)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Daily', style: TextStyle(color: Colors.white)),
                            SizedBox(
                              width: 50,
                              child: TextFormField(
                                initialValue: '$_goal',
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                onChanged: (value) {
                                  setDialogState(() {
                                    _goal = int.parse(value);
                                  });
                                  setState(() {
                                    _goal = int.parse(value);
                                  });
                                },
                              ),
                            ),
                            DropdownButton<String>(
                              value: _unitType,
                              dropdownColor: Provider.of<ThemeNotifier>(context).isDarkMode
                                  ? Colors.grey[850]!
                                  : const Color(0xFF0088CC),
                              style: const TextStyle(color: Colors.white),
                              onChanged: (String? newValue) {
                                setDialogState(() {
                                  _unitType = newValue!;
                                });
                                setState(() {
                                  _unitType = newValue!;
                                });
                              },
                              items: <String>['Count', 'Cup', 'Milliliter', 'Hour', 'Kilometer']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done', style: TextStyle(color: Colors.orange)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
