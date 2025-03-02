import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'screens/home_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/settings_screen.dart'; // Import SettingsScreen
import 'providers/tally_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_notifier.dart';
import 'providers/notification_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'screens/login_screen.dart';
import 'package:logging/logging.dart';
import 'config.dart'; // Import the config file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('Stack trace:\n${record.stackTrace}');
    }
  });
  
  // Load environment variables
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    // Continue without .env file, we'll use hardcoded values from config.dart
  }
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  tz.initializeTimeZones();
  await _requestPermissions();
  await NotificationHelper().initializeNotifications();

  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProxyProvider<UserProvider, TallyProvider>(
            create: (context) => TallyProvider(context.read<UserProvider>()),
            update: (context, userProvider, tallyProvider) =>
                tallyProvider!..updateUserProvider(userProvider),
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
    final userProvider = Provider.of<UserProvider>(context);

    return MaterialApp(
      title: 'Task Up',
      theme: ThemeData(
        primaryColor: const Color(0xFF0064A0),
        scaffoldBackgroundColor: const Color(0xFF0064A0),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0064A0),
          titleTextStyle: GoogleFonts.rubik(
            textStyle: const TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w500
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0064A0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: GoogleFonts.rubik(
            textStyle: const TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w500
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: userProvider.supabaseUser == null ? LoginScreen() : const HomeScreenWrapper(),
      routes: {
        '/home': (context) => const MyHomePage(title: 'TaskMe'),
        '/settings': (context) => const SettingsScreen(),
        '/timer': (context) => const TimerScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  _HomeScreenWrapperState createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: const HomeScreen(),
    );
  }
}
