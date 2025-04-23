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
  bool _isEditing = false;
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
          // Perfil Block editable
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _isEditing ? _pickImage : null,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _profileImageUrl.isNotEmpty
                              ? FileImage(File(_profileImageUrl))
                              : const AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _usernameController,
                              enabled: _isEditing,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _isEditing ? Colors.grey : Colors.black
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Nom d\'usuari',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _username = value;
                                });
                              },
                            ),
                            TextField(
                              controller: _nameController,
                              enabled: _isEditing,
                              style: TextStyle(
                                color: _isEditing ? Colors.grey : Colors.black,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Nom',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _name = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit),
                        onPressed: () {
                          if (_isEditing) {
                            _saveUserData();
                          }
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Definició',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isEditing ? Colors.grey : Colors.black
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _definitionController,
                    enabled: _isEditing,
                    maxLines: null,
                    style: TextStyle(
                      color: _isEditing ? Colors.grey : Colors.black,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Escriu una definició...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _definition = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Display points
          Text(
            'Punts: $_points',
            style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
          ),

          const SizedBox(height: 20),
          _points > 50
              ? Image.asset('assets/award_gold.png')
              : _points > 20
                  ? Image.asset('assets/award_silver.png')
                  : Image.asset('assets/award_bronze.png'),

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
