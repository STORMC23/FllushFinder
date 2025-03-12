import 'package:flutter/material.dart';

class Configuracio extends StatelessWidget {
  const Configuracio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkTheme = false;
  bool isVibrationEnabled = false;
  double volume = 0.5;
  String selectedLanguage = 'Català';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Proposar nova ubicació'),
            _buildSectionTitle('Idioma'),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: ['Català', 'castellà', 'Anglès'].map((lang) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(lang),
                    selected: selectedLanguage == lang,
                    onSelected: (selected) {
                      setState(() {
                        selectedLanguage = lang;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Sonido'),
            Slider(
              value: volume,
              onChanged: (newVolume) {
                setState(() {
                  volume = newVolume;
                });
              },
              min: 0,
              max: 1,
              divisions: 10,
            ),
            _buildToggle('Tema', isDarkTheme, (value) {
              setState(() {
                isDarkTheme = value;
              });
            }),
            _buildToggle('Vibració', isVibrationEnabled, (value) {
              setState(() {
                isVibrationEnabled = value;
              });
            }),
            const SizedBox(height: 16),
            _buildSectionTitle('Notificacions'),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Sortir (logout)',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildToggle(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
