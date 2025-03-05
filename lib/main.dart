import 'package:flutter/material.dart';
import 'screens/Splash.dart';

void main() {
  runApp(const BathroomFinderApp());
}

class BathroomFinderApp extends StatelessWidget {
  const BathroomFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
