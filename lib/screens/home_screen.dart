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

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _pageController = PageController(initialPage: 1000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TallyProvider>(context, listen: false).loadTallies();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
    if (_currentDate.year == now.year && _currentDate.month == now.month && _currentDate.day == now.day) {
      return "Today";
    } else if (_currentDate.year == now.year && _currentDate.month == now.month && _currentDate.day == now.day + 1) {
      return "Tomorrow";
    } else if (_currentDate.year == now.year && _currentDate.month == now.month && _currentDate.day == now.day - 1) {
      return "Yesterday";
    } else {
      return "${DateFormat('EEEE').format(_currentDate)}, ${DateFormat('d').format(_currentDate)}";
    }
  }

  String _getAppBarSubtitle() {
    return DateFormat('MMMM').format(_currentDate);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _currentDate = date;
      _isPageChanging = true;
      int daysDifference = date.difference(DateTime.now().startOfDay()).inDays;
      _pageController.jumpToPage(1000 + daysDifference);
    });
  }

  void _showConfetti(ConfettiController confettiController) {
    confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                TextSpan(
                  text: _getAppBarTitle(),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                TextSpan(
                  text: "\n${_getAppBarSubtitle()}",
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          SizedBox(
            height: 70,
            child: AnimationLimiter(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  String weekStart = Provider.of<TallyProvider>(context).weekStart;
                  int startDay = weekStart == 'Sunday' ? DateTime.sunday : DateTime.monday;
                  
                  // Calculate the start of the week based on the current date and week start preference
                  DateTime now = DateTime.now();
                  DateTime startOfWeek = _currentDate.subtract(
                    Duration(days: (_currentDate.weekday - startDay + 7) % 7)
                  );
                  
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
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('E').format(date),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.orange : (isToday ? Colors.white.withOpacity(0.3) : Colors.transparent),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    DateFormat('d').format(date),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
                    _currentDate = DateTime.now().startOfDay().add(Duration(days: index - 1000));
                  });
                } else {
                  _isPageChanging = false;
                }
              },
              itemBuilder: (context, index) {
                DateTime date = DateTime.now().startOfDay().add(Duration(days: index - 1000));
                return _buildCounterGrid(context, date);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF0064A0),
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.white),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.white),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.white),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer, color: Colors.white),
            label: 'Timer',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        selectedFontSize: 16,
        unselectedFontSize: 14,
        iconSize: 30,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildCounterGrid(BuildContext context, DateTime date) {
    return Consumer<TallyProvider>(
      builder: (context, tallyProvider, child) {
        List<Tally> filteredTallies = tallyProvider.getTalliesForDate(date);
        return AnimationLimiter(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filteredTallies.length,
            itemBuilder: (context, index) {
              final tally = filteredTallies[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: TallyCard(
                      tally: tally,
                      date: date,
                      showConfetti: (confettiController) => _showConfetti(confettiController),
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
