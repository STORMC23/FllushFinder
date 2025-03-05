import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  File? _profileImage;

  // Mètode per seleccionar una imatge de la galeria
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Mètode per mostrar la finestra de diàleg per editar les dades
  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Gmail'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contrasenya'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Cartellera amb el nom i correu de l'usuari
              GestureDetector(
                onTap: _editProfile, // Permet editar al clicar a la cartellera
                child: Card(
                  elevation: 4.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                    ),
                    title: Text(_nameController.text.isEmpty ? 'Nom d\'usuari' : _nameController.text),
                    subtitle: Text(_emailController.text.isEmpty ? 'user@gmail.com' : _emailController.text),
                    trailing: const Icon(Icons.edit),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Seleccionar imatge de perfil
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                  child: _profileImage == null
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Camp per editar el nom
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Camp per editar la contrasenya
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contrasenya',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Scroll amb icones de lavabo
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: 10,  // Pots ajustar el nombre d'icones
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.bathroom,
                        size: 40,
                        color: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
