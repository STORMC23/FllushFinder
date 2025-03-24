import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/Register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _gmailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _showError("Error d'autenticació: Credencials incorrectes");
      } else {
        String userId = response.user?.id ?? '';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userId: userId,)),
        );
      }
    } catch (e) {
      _showError("Error en l'inici de sessió: $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildDecorativeBubbles(),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAppIcon(),
                SizedBox(height: 20),
                Text(
                  'Iniciar Sessió',
                  style: GoogleFonts.lobster(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                buildTextField(_gmailController, 'Correu Electrònic', Icons.email),
                SizedBox(height: 20),
                buildTextField(_passwordController, 'Contrasenya', Icons.lock, obscureText: true),
                SizedBox(height: 40),
                _buildLoginButton(),
                SizedBox(height: 20),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeBubbles() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Icon(Icons.bubble_chart, size: 200, color: Colors.white.withOpacity(0.2)),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Icon(Icons.bubble_chart, size: 200, color: Colors.white.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildAppIcon() {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      child: Icon(Icons.wc, size: 100.0, color: Colors.white),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: _buttonStyle(),
      child: Text(
        'Entrar',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()),
        );
      },
      style: _buttonStyle(),
      child: Text(
        'Registrar-se',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white),
        ),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.blueAccent.withOpacity(0.3),
      ),
    );
  }
}
