import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/tally.dart';
import '/providers/tally_provider.dart';
import '/screens/edit_tally_screen.dart';
import '/screens/statistics_screen.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class TallyCard extends StatefulWidget {
  final Tally tally;
  final DateTime date;
  final Function(ConfettiController) showConfetti;

  const TallyCard({super.key, required this.tally, required this.date, required this.showConfetti});

  @override
  _TallyCardState createState() => _TallyCardState();
}

class _TallyCardState extends State<TallyCard> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('yyyy-MM-dd').format(widget.date);
    final currentValue = widget.tally.dailyValues[dateString] ?? 0;

    final now = DateTime.now();
    final difference = now.difference(widget.tally.lastModified);
    String timeText;
    if (widget.tally.showQuoteInsteadOfTime) {
      timeText = widget.tally.quote;
    } else {
      if (difference.inMinutes < 1) {
        timeText = 'just now';
      } else if (difference.inMinutes < 60) {
        timeText = '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        timeText = '${difference.inHours} hours ago';
      } else {
        timeText = '${difference.inDays} days ago';
      }
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            final wasTargetReached = widget.tally.setTarget && widget.tally.targetValue > 0 && currentValue < widget.tally.targetValue;

            Provider.of<TallyProvider>(context, listen: false).incrementTally(widget.tally, widget.date);

            final isTargetReachedNow = widget.tally.setTarget && widget.tally.targetValue > 0 && currentValue + 1 >= widget.tally.targetValue;

            if (wasTargetReached && isTargetReachedNow) {
              widget.showConfetti(_confettiController);
            }
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => _buildBottomSheet(context, widget.tally),
            );
          },
          child: Card(
            color: Color(widget.tally.color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.tally.title,
                        style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.tally.setTarget && widget.tally.targetValue > 0 ? '$currentValue / ${widget.tally.targetValue}' : '$currentValue',
                        style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (DateFormat('yyyy-MM-dd').format(widget.date) == DateFormat('yyyy-MM-dd').format(now))
                    Flexible(
                      flex: 1,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          timeText,
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IconButton(
                      icon: const Icon(Icons.bar_chart, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatisticsScreen(tally: widget.tally),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2, // upwards
            maxBlastForce: 5, // set a lower max blast force
            minBlastForce: 2, // set a lower min blast force
            emissionFrequency: 0.05,
            numberOfParticles: 20, // a lot of particles at once
            gravity: 0.05,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(BuildContext context, Tally tally) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Add Count'),
          onTap: () {
            Navigator.pop(context);
            _showAddCountDialog(context, tally);
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit Tally'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTallyScreen(tally: tally),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete Tally'),
          onTap: () {
            Navigator.pop(context);
            Provider.of<TallyProvider>(context, listen: false).removeTally(tally);
          },
        ),
      ],
    );
  }

  void _showAddCountDialog(BuildContext context, Tally tally) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController customCountController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Custom Count'),
          content: TextField(
            controller: customCountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.blue),
            decoration: const InputDecoration(
              hintText: 'Enter count',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final int? customCount = int.tryParse(customCountController.text);
                if (customCount != null) {
                  Provider.of<TallyProvider>(context, listen: false).incrementTally(tally, widget.date, customCount);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
