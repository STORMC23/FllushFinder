// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomeScreen.dart';
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Icon(
              Icons.bubble_chart,
              size: 200,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Icon(
              Icons.bubble_chart,
              size: 200,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Flush Finder',
                style: GoogleFonts.lobster(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Image.asset(
                  'assets/Splash/ToiletSplash.png',
                  width: 150,
                ),
              ),
              const SizedBox(height: 50),
              /*ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(25),
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black54,
                  elevation: 10,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Icon(
                  Icons.wc,
                  size: 50,
                  color: Colors.blueAccent,
                ),
              ),*/
              const SizedBox(height: 20),
              Text(
                'Flush the doubt, find the spot!',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
