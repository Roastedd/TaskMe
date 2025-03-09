import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/tally.dart';
import '/providers/tally_provider.dart';
import '/screens/edit_tally_screen.dart';
import '/screens/statistics_screen.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';

class TallyCard extends StatefulWidget {
  final Tally tally;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onIncrement;

  const TallyCard({
    super.key,
    required this.tally,
    required this.onTap,
    required this.onLongPress,
    required this.onIncrement,
  });

  @override
  State<TallyCard> createState() => _TallyCardState();
}

class _TallyCardState extends State<TallyCard>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode
        ? Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 255)
        : Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 255);
    final dateString =
        DateFormat('yyyy-MM-dd').format(widget.tally.lastModified);
    final currentValue = widget.tally.dailyValues[dateString] ?? 0;

    final now = DateTime.now();
    final difference = now.difference(widget.tally.lastModified);
    String timeText;
    if (widget.tally.showQuoteInsteadOfTime) {
      timeText = widget.tally.quote ?? 'No quote available';
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

    // Calculate progress percentage for the progress indicator
    double progressPercentage = 0.0;
    if (widget.tally.setTarget && widget.tally.targetValue > 0) {
      progressPercentage =
          (currentValue / widget.tally.targetValue).clamp(0.0, 1.0);
    }

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();

              final wasTargetReached = widget.tally.setTarget &&
                  widget.tally.targetValue > 0 &&
                  currentValue < widget.tally.targetValue;

              Provider.of<TallyProvider>(context, listen: false)
                  .incrementTally(widget.tally, widget.tally.lastModified);

              final isTargetReachedNow = widget.tally.setTarget &&
                  widget.tally.targetValue > 0 &&
                  currentValue + 1 >= widget.tally.targetValue;

              if (wasTargetReached && isTargetReachedNow) {
                widget.onIncrement();
              }
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            onLongPress: () {
              _animationController.reverse();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => _buildBottomSheet(context, widget.tally),
              );
            },
            child: Card(
              color: Theme.of(context).colorScheme.primary.withAlpha(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: _isPressed ? 1 : 4,
              shadowColor:
                  Theme.of(context).colorScheme.secondary.withAlpha(15),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withAlpha(15),
                      Theme.of(context).colorScheme.primary.withAlpha(20),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).colorScheme.primary.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Text(
                          widget.tally.title,
                          style: TextStyle(
                            fontSize: 20,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(
                                blurRadius: 2.0,
                                color: Colors.black26,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).animate().fadeIn(duration: 400.ms).slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutQuad),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        flex: 3,
                        child: widget.tally.setTarget &&
                                widget.tally.targetValue > 0
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$currentValue / ${widget.tally.targetValue}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: Colors.black26,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                      .animate()
                                      .fadeIn(duration: 400.ms, delay: 100.ms)
                                      .scale(
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1, 1),
                                          duration: 400.ms,
                                          curve: Curves.easeOutBack),

                                  const SizedBox(height: 8),

                                  // Progress bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progressPercentage,
                                      minHeight: 10,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withAlpha(15),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          progressPercentage >= 1.0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(20)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(15)),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 400.ms, delay: 200.ms)
                                      .slideX(
                                          begin: -0.2,
                                          end: 0,
                                          duration: 400.ms,
                                          curve: Curves.easeOutQuad),
                                ],
                              )
                            : Text(
                                '$currentValue',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 2.0,
                                      color: Colors.black26,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 100.ms)
                                .scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1, 1),
                                    duration: 400.ms,
                                    curve: Curves.easeOutBack),
                      ),
                      const SizedBox(height: 8),
                      if (DateFormat('yyyy-MM-dd')
                              .format(widget.tally.lastModified) ==
                          DateFormat('yyyy-MM-dd').format(now))
                        Flexible(
                          flex: 1,
                          child: Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.bar_chart,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StatisticsScreen(tally: widget.tally),
                                ),
                              );
                            },
                            tooltip: 'View Statistics',
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 400.ms)
                              .scale(
                                  begin: const Offset(0.5, 0.5),
                                  end: const Offset(1, 1),
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditTallyScreen(tally: widget.tally),
                                ),
                              );
                            },
                            tooltip: 'Edit Tally',
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 500.ms)
                              .scale(
                                  begin: const Offset(0.5, 0.5),
                                  end: const Offset(1, 1),
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack),
                        ],
                      ),
                    ],
                  ),
                ),
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
            numberOfParticles: 30, // more particles for better effect
            gravity: 0.05,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(BuildContext context, Tally tally) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.blue),
            ),
            title: const Text('Add Custom Count',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Add a specific number to your tally'),
            onTap: () {
              Navigator.pop(context);
              _showAddCountDialog(context, tally);
            },
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit, color: Colors.orange),
            ),
            title: const Text('Edit Tally',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Modify tally settings and appearance'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTallyScreen(tally: tally),
                ),
              );
            },
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            title: const Text('Delete Tally',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Remove this tally permanently'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog(context, tally);
            },
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddCountDialog(BuildContext context, Tally tally) {
    final TextEditingController customCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Count'),
          content: TextField(
            controller: customCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter count',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.add_circle_outline),
            ),
            autofocus: true,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                final int? customCount =
                    int.tryParse(customCountController.text);
                if (customCount != null) {
                  Provider.of<TallyProvider>(context, listen: false)
                      .incrementTally(
                          tally, widget.tally.lastModified, customCount);
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withAlpha(15),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Tally tally) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Tally'),
          content: Text(
              'Are you sure you want to delete "${tally.title}"? This action cannot be undone.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                Provider.of<TallyProvider>(context, listen: false)
                    .removeTally(tally);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.error.withAlpha(20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
