import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    const textColor = Colors.white;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);
    final cardColor = isDarkMode ? Colors.grey[850] : const Color(0xFF0088CC);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: backgroundColor,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: cardColor,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tally Counter App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Version: 1.0.0',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'The Tally Counter App helps you keep track of counts in a simple and efficient way. Whether you are counting people, items, or any other thing, this app provides an easy-to-use interface to tally your counts.',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '- Simple and intuitive interface\n'
                          '- Multiple counters\n'
                          '- Dark mode support\n'
                          '- Customizable settings\n'
                          '- Backup and restore options',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Developed by Edward Leyco',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
