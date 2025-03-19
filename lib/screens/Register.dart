import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/Login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
    try {
      final email = _gmailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();
      final name = _nameController.text.trim();

      if (email.isEmpty || password.isEmpty || username.isEmpty || name.isEmpty) {
        _showError("Tots els camps són obligatoris.");
        return;
      }

      final signUpResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (signUpResponse.user == null) {
        _showError("No s'ha pogut registrar l'usuari.");
        return;
      }

      final userId = signUpResponse.user!.id;

      await Supabase.instance.client.from('Users').insert([
        {'UID': userId, 'Email': email}
      ]);

      final existingUser = await Supabase.instance.client.from('usuaris')
          .select()
          .eq('id_usuaris', userId)
          .maybeSingle();

      if (existingUser == null) {
        await Supabase.instance.client.from('usuaris').insert([
          {
            'id_usuaris': userId,
            'username': username,
            'name': name,
            'punts': 0,
            'imatge': '',
          }
        ]);
      }

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      _showError("Error inesperat: $e");
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Registre', style: GoogleFonts.lobster(fontSize: 40, color: Colors.white)),
              SizedBox(height: 20),
              buildTextField(_usernameController, 'Username', Icons.person),
              SizedBox(height: 20),
              buildTextField(_nameController, 'Nom', Icons.person),
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

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      );

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
