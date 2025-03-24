import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({super.key, required this.userId});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();
  
  String _username = '';
  String _name = '';
  int _points = 0;
  String _profileImageUrl = '';
  String _definition = '';
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _definitionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await _supabase
          .from('usuari')
          .select('username, name, punts, imatge, definicio')
          .eq('id_usuaris', widget.userId)
          .single();

      if (response != null && response.isNotEmpty) {
        setState(() {
          _username = response['username'] ?? 'Nom d\'usuari no disponible';
          _name = response['name'] ?? 'Nom no disponible';
          _points = response['punts'] is int ? response['punts'] : 0;
          _profileImageUrl = response['imatge'] ?? '';
          _definition = response['definicio'] ?? '';
          _usernameController.text = _username;
          _nameController.text = _name;
          _definitionController.text = _definition;
        });
      } else {
        print('No s\'ha trobat cap usuari amb aquest ID');
      }
    } catch (e) {
      print('Error carregant les dades de l\'usuari: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageUrl = pickedFile.path;
      });
    }
  }

  Future<void> _saveUserData() async {
  try {
    // Perform the upsert operation
    final response = await _supabase.from('usuari').upsert({
      'id_usuaris': widget.userId,
      'username': _username,
      'name': _name,
      'punts': _points,
      'imatge': _profileImageUrl,
      'definicio': _definition,
    }).select().single();

    if (response != null && response is PostgrestMap) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualitzat correctament')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error actualitzant el perfil')));
    }
  } catch (e) {
    print('Error actualitzant les dades de l\'usuari: $e');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de l\'usuari'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Perfil Image
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageUrl.isNotEmpty
                  ? FileImage(File(_profileImageUrl))
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
            ),
          ),
          const SizedBox(height: 20),

          // Nom and Username Fields
          _buildEditableCard(
            title: 'Nom',
            controller: _nameController,
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildEditableCard(
            title: 'Nom d\'usuari',
            controller: _usernameController,
            onChanged: (value) {
              setState(() {
                _username = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Definició Field
          _buildEditableCard(
            title: 'Definició',
            controller: _definitionController,
            onChanged: (value) {
              setState(() {
                _definition = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Display points
          Text(
            'Punts: $_points',
            style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
          ),

          // Show images based on points
          const SizedBox(height: 20),
          _points > 50
              ? Image.asset('assets/award_gold.png') // You can put images based on points
              : _points > 20
                  ? Image.asset('assets/award_silver.png')
                  : Image.asset('assets/award_bronze.png'),

          // Save button
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveUserData,
            child: const Text('Guardar canvis'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard({
    required String title,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
