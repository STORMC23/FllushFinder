import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomeScreen.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Fons de color blau com SplashScreen
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Icon(
              Icons.bubble_chart, // Icònica divertida de boles, per mantenir l'estil
              size: 200,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Icon(
              Icons.bubble_chart, // Doble icona per a l'estil
              size: 200,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icònica divertida de lavabo
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.wc, // Icona relacionada amb el lavabo
                      size: 100.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Títol amb una font més personalitzada
                  Text(
                    'Flush Finder Login',
                    style: GoogleFonts.lobster(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Camp de text per a Nom d'usuari
                  buildTextField(_usernameController, 'Nom d\'usuari', Icons.person),
                  SizedBox(height: 20),

                  // Camp de text per a Gmail
                  buildTextField(_gmailController, 'Gmail', Icons.email),
                  SizedBox(height: 20),

                  // Camp de text per a Contrasenya
                  buildTextField(_passwordController, 'Contrasenya', Icons.lock, obscureText: true),
                  SizedBox(height: 40),

                  // Botó d'entrada amb un estil més adequat
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      /*if (_usernameController.text.isNotEmpty &&
                          _gmailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      } else {
                        print('Omple tots els camps!');
                      }*/
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Botó blanc per fer contrast
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8, // Ombra per destacar el botó
                    ),
                    child: Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent, // Color blau per al text
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Funció per crear els camps de text amb estil
  Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),  // Text blanc per als camps
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white), // Color blanc per a les etiquetes
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white), // Borde blanc
        ),
        prefixIcon: Icon(icon, color: Colors.white), // Icona blanca
        filled: true,
        fillColor: Colors.blueAccent.withOpacity(0.3), // Fons de color suau
      ),
    );
  }
}
