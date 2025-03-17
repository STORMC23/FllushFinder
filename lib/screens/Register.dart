import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomeScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _register() async {
    final email = _gmailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final name = _nameController.text.trim();

    try {
      // Intentar registrar l'usuari
      final signUpResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final userId = signUpResponse.user!.id;

      // Insertar a la taula 'Users'
      final usersResponse = await Supabase.instance.client.from('Users').insert([
        {'UID': userId, 'Email': email}
      ]);

      // Insertar a la taula 'Usuaris' (amb cometes per respectar la capitalització)
      final usuarisResponse = await Supabase.instance.client.from('"Usuaris"').insert([
        {'id_usuaris': userId, 'username': username, 'name': name, 'punts': 0, 'imatge': ''}
      ]);
      // Redirigir a la pantalla principal després de l'èxit
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      _showError("Error en el registre: $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Registre', style: GoogleFonts.lobster(fontSize: 40, color: Colors.white)),
              SizedBox(height: 20),
              buildTextField(_usernameController, 'Usename d\'usuari', Icons.person),
              SizedBox(height: 20),
              buildTextField(_nameController, 'Nom d\'usuari', Icons.person),
              SizedBox(height: 20),
              buildTextField(_gmailController, 'Gmail', Icons.email),
              SizedBox(height: 20),
              buildTextField(_passwordController, 'Contrasenya', Icons.lock, obscureText: true),
              SizedBox(height: 40),
              ElevatedButton(onPressed: _register, style: _buttonStyle(), child: Text('Registrar-se')),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15));

  Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(controller: controller, obscureText: obscureText, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)));
  }
}
