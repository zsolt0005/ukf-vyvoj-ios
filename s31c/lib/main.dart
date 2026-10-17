import 'package:flutter/material.dart';
import 'package:seminar_1/styled_text.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: GradientScreen(),
      ),
    ),
  );
}

class GradientScreen extends StatelessWidget {
  const GradientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A148C),
            Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: StyledText('Hello Gradient!', bold: true),
      ),
    );
  }
}
