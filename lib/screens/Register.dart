import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/Login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// Primera classe: Registre a la taula 'users'
class RegisterUsersScreen extends StatefulWidget {
  @override
  _RegisterUsersScreenState createState() => _RegisterUsersScreenState();
}

class _RegisterUsersScreenState extends State<RegisterUsersScreen> {
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUsers() async {
    try {
      // Obtenir valors dels camps
      final email = _gmailController.text.trim();
      final password = _passwordController.text.trim();

      // Validar els camps del formulari
      if (email.isEmpty || password.isEmpty) {
        _showError("Tots els camps són obligatoris.");
        return;
      }

      // Registra l'usuari a la taula 'users'
      final signUpResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      // Comprovar si l'usuari s'ha registrat correctament
      if (signUpResponse.user == null) {
        _showError("No s'ha pogut registrar l'usuari.");
        return;
      }

      final userId = signUpResponse.user!.id; // Obtenir el UUID generat
      print("UserID obtingut: $userId");

      // Navegar a la pantalla següent per completar el registre
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterUsuariScreen(userId: userId),
        ),
      );
    } catch (e) {
      print("Error inesperat: $e");
      _showError("Ha ocorregut un error inesperat: $e");
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Registre - Correu i Contrasenya', style: GoogleFonts.lobster(fontSize: 30, color: Colors.white)),
              SizedBox(height: 20),
              buildTextField(_gmailController, 'Correu electrònic', Icons.email),
              SizedBox(height: 20),
              buildTextField(_passwordController, 'Contrasenya', Icons.lock, obscureText: true),
              SizedBox(height: 40),
              ElevatedButton(onPressed: _registerUsers, style: _buttonStyle(), child: Text('Continuar')),
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

/// Segona classe: Registre a la taula 'usuari'
class RegisterUsuariScreen extends StatefulWidget {
  final String userId; // ID generat en la primera pantalla

  RegisterUsuariScreen({required this.userId});

  @override
  _RegisterUsuariScreenState createState() => _RegisterUsuariScreenState();
}

class _RegisterUsuariScreenState extends State<RegisterUsuariScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  Future<void> _registerUsuari() async {
  try {
    final response = await Supabase.instance.client.from('usuari').upsert({
      'id_usuaris': widget.userId,
      'username': _usernameController.text.trim(),
      'name': _nameController.text.trim(),
      'punts': 0,
      'imatge': _imageController.text.trim(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  } catch (e) {
    print(e);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Registre - Dades Usuari', style: GoogleFonts.lobster(fontSize: 30, color: Colors.white)),
              SizedBox(height: 20),
              buildTextField(_usernameController, 'Nom d\'usuari', Icons.person),
              SizedBox(height: 20),
              buildTextField(_nameController, 'Nom complet', Icons.person),
              SizedBox(height: 20),
              buildTextField(_imageController, 'URL de la imatge', Icons.image),
              SizedBox(height: 40),
              ElevatedButton(onPressed: _registerUsuari, style: _buttonStyle(), child: Text('Registrar-se')),
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
