import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/ThemeProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/Splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
     url: 'https://vtxwdcwttnmspejvkdou.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0eHdkY3d0dG5tc3BlanZrZG91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE2MjYxNzYsImV4cCI6MjA1NzIwMjE3Nn0.OpCPxvDEgGWDn6c--psjSla_9U-H6a5UWKWDqN9C4LY',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const BathroomFinderApp(),
    ),
  );
}

class BathroomFinderApp extends StatelessWidget {
  const BathroomFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const SplashScreen(), // La pantalla inicial
    );
  }
}
