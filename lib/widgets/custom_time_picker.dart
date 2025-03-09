import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePicker({super.key, required this.initialTime});

  @override
  CustomTimePickerState createState() => CustomTimePickerState();
}

class CustomTimePickerState extends State<CustomTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  bool _isAm = true;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hourOfPeriod;
    _selectedMinute = widget.initialTime.minute;
    _isAm = widget.initialTime.period == DayPeriod.am;
  }

  @override
  Widget build(BuildContext context) {
    const selectedTextStyle = TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold);
    const textStyle = TextStyle(color: Colors.grey, fontSize: 24);

    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Text('Time', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumberPicker(
                value: _selectedHour,
                minValue: 1,
                maxValue: 12,
                onChanged: (value) {
                  setState(() {
                    _selectedHour = value;
                  });
                },
                textStyle: textStyle,
                selectedTextStyle: selectedTextStyle,
                itemWidth: 60,
                zeroPad: true,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.orange, width: 2),
                    bottom: BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
              ),
              const Text(':', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              NumberPicker(
                value: _selectedMinute,
                minValue: 0,
                maxValue: 59,
                onChanged: (value) {
                  setState(() {
                    _selectedMinute = value;
                  });
                },
                textStyle: textStyle,
                selectedTextStyle: selectedTextStyle,
                itemWidth: 60,
                zeroPad: true,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.orange, width: 2),
                    bottom: BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAm = true;
                      });
                    },
                    child: Text(
                      'AM',
                      style: TextStyle(
                        color: _isAm ? Colors.orange : Colors.grey,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAm = false;
                      });
                    },
                    child: Text(
                      'PM',
                      style: TextStyle(
                        color: !_isAm ? Colors.orange : Colors.grey,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            final hour = _isAm ? _selectedHour : (_selectedHour == 12 ? 12 : _selectedHour + 12);
            final time = TimeOfDay(hour: hour, minute: _selectedMinute);
            Navigator.of(context).pop(time);
          },
          child: const Text('Done', style: TextStyle(color: Colors.orange)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(const TimeOfDay(hour: -1, minute: 0)); // To handle the clear action
          },
          child: const Text('Clear', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
