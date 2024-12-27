import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'screens/home_screen.dart';
import 'screens/timer_screen.dart';
import 'providers/tally_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_notifier.dart';
import 'providers/notification_helper.dart';
import 'providers/social_auth_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  await _requestPermissions();
  await NotificationHelper().initializeNotifications();

  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => SocialAuthProvider()),
          ChangeNotifierProxyProvider<UserProvider, TallyProvider>(
            create: (context) => TallyProvider(context.read<UserProvider>()),
            update: (context, userProvider, tallyProvider) => tallyProvider!..updateUserProvider(userProvider),
          ),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> _requestPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (await Permission.systemAlertWindow.isDenied) {
    await Permission.systemAlertWindow.request();
  }

  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }

  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Task Up',
      theme: ThemeData(
        primaryColor: const Color(0xFF0064A0),
        scaffoldBackgroundColor: const Color(0xFF0064A0),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0064A0),
          titleTextStyle: GoogleFonts.rubik(
            textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF0064A0),
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.rubik(textStyle: const TextStyle(color: Colors.white)),
          bodyMedium: GoogleFonts.rubik(textStyle: const TextStyle(color: Colors.white)),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: GoogleFonts.rubik(
            textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.rubik(textStyle: const TextStyle(color: Colors.white)),
          bodyMedium: GoogleFonts.rubik(textStyle: const TextStyle(color: Colors.white)),
        ),
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreenWrapper(),
      routes: {
        '/timer': (context) => const TimerScreen(),
        // Removed TestScreen route
      },
    );
  }
}

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  _HomeScreenWrapperState createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
