import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

void main() async {
  // Create a picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Define the size (1024x1024 is recommended for app icons)
  const size = Size(1024, 1024);

  // Draw background
  final paint = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, size.height),
      [
        const Color(0xFF6750A4), // Primary color
        const Color(0xFF9780D8), // Lighter shade
      ],
    );
  canvas.drawRect(Offset.zero & size, paint);

  // Draw task list icon
  final iconPaint = Paint()
    ..color = Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 242)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 50
    ..strokeCap = StrokeCap.round;

  // Draw clipboard outline
  final clipboardPath = Path()
    ..moveTo(size.width * 0.3, size.height * 0.2)
    ..lineTo(size.width * 0.3, size.height * 0.8)
    ..lineTo(size.width * 0.7, size.height * 0.8)
    ..lineTo(size.width * 0.7, size.height * 0.2)
    ..close();
  canvas.drawPath(clipboardPath, iconPaint);

  // Draw task lines
  canvas.drawLine(
    Offset(size.width * 0.4, size.height * 0.4),
    Offset(size.width * 0.6, size.height * 0.4),
    iconPaint,
  );
  canvas.drawLine(
    Offset(size.width * 0.4, size.height * 0.6),
    Offset(size.width * 0.6, size.height * 0.6),
    iconPaint,
  );

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Save the file
  final file = File('assets/icon/app_icon.png');
  await file.writeAsBytes(buffer);

  developer.log('Icon generated successfully!');
  exit(0);
}

class IconGenerator {
  static const Map<String, IconData> _iconMap = {
    // ... existing code ...
  };

  static IconData getIconForName(String name) {
    final lowercaseName = name.toLowerCase();
    for (final entry in _iconMap.entries) {
      if (lowercaseName.contains(entry.key)) {
        return entry.value;
      }
    }
    developer.log('No matching icon found for: $name', name: 'IconGenerator');
    return Icons.check_box_outline_blank;
  }
}
