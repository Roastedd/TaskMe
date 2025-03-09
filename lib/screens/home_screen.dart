import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/providers/tally_provider.dart';
import '/widgets/tally_card.dart';
import 'package:intl/intl.dart';
import '/models/tally.dart';
import '/providers/theme_notifier.dart';
import '/screens/create_tally_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/player_statistics_screen.dart';
import '/screens/timer_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '/screens/tally_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late DateTime _currentDate;
  int _selectedIndex = 1;
  bool _isPageChanging = false;
  late AnimationController _fabAnimationController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _pageController = PageController(initialPage: 1000);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TallyProvider>(context, listen: false).loadTallies();
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _navigateToScreen(const SettingsScreen());
        break;
      case 1:
        _navigateToScreen(const CreateTallyScreen());
        break;
      case 2:
        _navigateToScreen(const PlayerStatisticsScreen());
        break;
      case 3:
        _navigateToScreen(const TimerScreen());
        break;
      default:
        break;
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  String _getAppBarTitle() {
    final now = DateTime.now();
    if (_currentDate.year == now.year &&
        _currentDate.month == now.month &&
        _currentDate.day == now.day) {
      return "Today";
    } else if (_currentDate.year == now.year &&
        _currentDate.month == now.month &&
        _currentDate.day == now.day + 1) {
      return "Tomorrow";
    } else if (_currentDate.year == now.year &&
        _currentDate.month == now.month &&
        _currentDate.day == now.day - 1) {
      return "Yesterday";
    } else {
      return "${DateFormat('EEEE').format(_currentDate)}, ${DateFormat('d').format(_currentDate)}";
    }
  }

  String _getAppBarSubtitle() {
    return DateFormat('MMMM yyyy').format(_currentDate);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _currentDate = date;
      _isPageChanging = true;
      int daysDifference = date.difference(DateTime.now().startOfDay()).inDays;
      _pageController.animateToPage(
        1000 + daysDifference,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final backgroundColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFF0064A0);

    final gradientColors = isDarkMode
        ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
        : [const Color(0xFF0064A0), const Color(0xFF004D7A)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getAppBarTitle(),
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(
                  begin: -0.2,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutQuad),
              Text(
                _getAppBarSubtitle(),
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(
                  begin: -0.2,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutQuad),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              _showDatePicker();
            },
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: kToolbarHeight + 16), // Space for AppBar

                SizedBox(
                  height: 80,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        String weekStart =
                            Provider.of<TallyProvider>(context).weekStart;
                        int startDay = weekStart == 'Sunday'
                            ? DateTime.sunday
                            : DateTime.monday;

                        // Calculate the start of the week based on the current date and week start preference
                        DateTime now = DateTime.now();
                        DateTime startOfWeek = _currentDate.subtract(Duration(
                            days: (_currentDate.weekday - startDay + 7) % 7));

                        // Calculate the date for this day in the week
                        DateTime date = startOfWeek.add(Duration(days: index));

                        // Check if this date is the selected date
                        bool isSelected = _currentDate.year == date.year &&
                            _currentDate.month == date.month &&
                            _currentDate.day == date.day;

                        // Check if this date is today
                        bool isToday = now.year == date.year &&
                            now.month == date.month &&
                            now.day == date.day;

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () => _onDateSelected(date),
                                child: Container(
                                  width: 60,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.orange.withAlpha(204)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('E').format(date),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.orange
                                              : Colors.white,
                                          fontWeight: isToday || isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.orange
                                              : (isToday
                                                  ? Colors.white.withAlpha(77)
                                                  : Colors.transparent),
                                          shape: BoxShape.circle,
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.orange
                                                        .withAlpha(128),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          DateFormat('d').format(date),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white,
                                            fontWeight: isToday || isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (!_isPageChanging) {
                        setState(() {
                          _currentDate = DateTime.now()
                              .startOfDay()
                              .add(Duration(days: index - 1000));
                        });
                      } else {
                        _isPageChanging = false;
                      }
                    },
                    itemBuilder: (context, index) {
                      DateTime date = DateTime.now()
                          .startOfDay()
                          .add(Duration(days: index - 1000));
                      return _buildCounterGrid(context, date);
                    },
                  ),
                ),
              ],
            ),

            // Confetti overlay for global celebrations
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -math.pi / 2, // straight up
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                maxBlastForce: 5,
                minBlastForce: 2,
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

            // FAB for adding new tally
            Positioned(
              right: 20,
              bottom: 80,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _fabAnimationController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    _navigateToScreen(const CreateTallyScreen());
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.add, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColors[1].withAlpha(204),
              gradientColors[1],
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings, color: Colors.white),
              label: 'Settings',
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(204),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings, color: Colors.orange),
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: 'Add',
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(204),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_circle, color: Colors.orange),
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              label: 'Stats',
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(204),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bar_chart, color: Colors.orange),
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.timer_outlined, color: Colors.white),
              label: 'Timer',
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(204),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer, color: Colors.orange),
              ),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 26,
          onTap: _onItemTapped,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0064A0),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0064A0),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _currentDate) {
      _onDateSelected(picked);
    }
  }

  Widget _buildCounterGrid(BuildContext context, DateTime date) {
    return Consumer<TallyProvider>(
      builder: (context, tallyProvider, child) {
        List<Tally> filteredTallies = tallyProvider.getTalliesForDate(date);

        if (filteredTallies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_task,
                  size: 80,
                  color: Colors.white.withAlpha(77),
                ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(
                  'No habits for this day',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white.withAlpha(179),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutQuad),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add a new habit',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withAlpha(128),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutQuad),
              ],
            ),
          );
        }

        return AnimationLimiter(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredTallies.length,
            itemBuilder: (context, index) {
              final tally = filteredTallies[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                  scale: 0.9,
                  child: FadeInAnimation(
                    child: TallyCard(
                      tally: tally,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TallyDetailScreen(tally: tally),
                          ),
                        );
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Tally'),
                            content: const Text(
                                'Are you sure you want to delete this tally?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Provider.of<TallyProvider>(context,
                                          listen: false)
                                      .deleteTally(tally.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onIncrement: () {
                        _confettiController.play();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime startOfDay() {
    return DateTime(year, month, day);
  }
}
