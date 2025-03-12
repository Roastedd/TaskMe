import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  final _logger = Logger('SplashScreen');

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Check authentication after animations
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Add a small delay for the animation
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      setState(() => _isLoading = false);

      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        _logger.info('User is authenticated, navigating to home screen');
        _navigateToScreen(const HomeScreen());
      } else {
        _logger.info('User is not authenticated, navigating to login screen');
        _navigateToScreen(const LoginScreen());
      }
    } catch (e, stackTrace) {
      _logger.severe('Error during authentication check', e, stackTrace);
      if (mounted) {
        _navigateToScreen(const LoginScreen());
      }
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var opacityAnimation = animation.drive(tween);
          return FadeTransition(opacity: opacityAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final gradientColors = isDarkMode
        ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
        : [const Color(0xFF0064A0), const Color(0xFF004D7A)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withValues(red: 255, green: 140, blue: 0, alpha: 77),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 120,
                              height: 120,
                            ),
                          ).animate().scale(
                                duration: 800.ms,
                                curve: Curves.easeOutBack,
                              ),
                          const SizedBox(height: 24),
                          Text(
                            'TaskMe',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(
                                delay: 400.ms,
                                duration: 800.ms,
                              ),
                          const SizedBox(height: 8),
                          Text(
                            'Build Better Habits',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 204),
                            ),
                          ).animate().fadeIn(
                                delay: 600.ms,
                                duration: 800.ms,
                              ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_isLoading) ...[
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ).animate().fadeIn(
                      delay: 800.ms,
                      duration: 400.ms,
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
