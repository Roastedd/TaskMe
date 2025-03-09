import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'screens/home_screen.dart';
import 'providers/tally_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_notifier.dart';
import 'package:taskme/screens/splash_screen.dart';

// Global key for navigator to use in error handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Config {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  _initializeLogging();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
    debug: true,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

void _initializeLogging() {
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

  Logger('App').info('Logging initialized');
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, TallyProvider>(
          create: (context) => TallyProvider(
            Provider.of<UserProvider>(context, listen: false),
            prefs,
          ),
          update: (context, userProvider, previous) =>
              TallyProvider(userProvider, prefs),
        ),
      ],
      child: Builder(builder: (context) {
        final themeNotifier = Provider.of<ThemeNotifier>(context);

        return MaterialApp(
          title: 'TaskMe',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness:
                themeNotifier.isDarkMode ? Brightness.dark : Brightness.light,
          ),
          home: const SplashScreen(),
          routes: {'/home': (context) => const HomeScreen()},
        );
      }),
    );
  }
}
