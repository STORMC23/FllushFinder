// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                onTap: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                  /*Soundpool pool = Soundpool(streamType: StreamType.notification); 
                  int soundId = await rootBundle.load("assets/wc.mp3").then((ByteData soundData) {
                    return pool.load(soundData);
                  });

                  pool.play(soundId); */

                  await Future.delayed(Duration(seconds: 7));
                },
                child: Image.asset(
                  'assets/Splash/ToiletSplash.png',
                  width: 150,
                ),
              ),
              const SizedBox(height: 70),
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
