import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/screens/Login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SettingsPage extends StatefulWidget {
  final String userId; // ID de l'usuari

  const SettingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkTheme = false;
  bool isVibrationEnabled = false;
  double volume = 0.5;
  String selectedLanguage = 'Català';

  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// **Carrega la configuració de l'usuari des de Supabase**
  Future<void> _loadSettings() async {
    final response = await supabase
        .from('configuracio')
        .select()
        .eq('id_usuari', widget.userId)
        .single();

    if (response != null) {
      setState(() {
        selectedLanguage = response['idioma'];
        isDarkTheme = response['tema'] == 'Dark';
        isVibrationEnabled = response['vibracio'] == true;
        volume = response['volum'] / 100.0;
      });
    }
  }

  /// **Actualitza la configuració de l'usuari a Supabase**
  Future<void> _updateSettings(String field, dynamic value) async {
    await supabase.from('configuracio').update({
      field: value,
    }).eq('id_usuari', widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkTheme ? darkTheme : lightTheme,
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white, // Canvia el fons segons el tema
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Idioma'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: ['Català', 'Castellà', 'Anglès'].map((lang) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        lang,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: selectedLanguage == lang,
                      selectedColor: isDarkTheme ? Colors.grey[700] : Colors.blue[100],
                      onSelected: (selected) {
                        setState(() {
                          selectedLanguage = lang;
                        });
                        _updateSettings('idioma', lang);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('So'),
              Slider(
                value: volume,
                activeColor: isDarkTheme ? Colors.blue[200] : Colors.blue,
                inactiveColor: isDarkTheme ? Colors.grey : Colors.blue[100],
                onChanged: (newVolume) {
                  setState(() {
                    volume = newVolume;
                  });
                  _updateSettings('volum', (newVolume * 100).toInt());
                },
                min: 0,
                max: 1,
                divisions: 10,
              ),
              _buildToggle('Tema', isDarkTheme, (value) {
                setState(() {
                  isDarkTheme = value;
                });
                _updateSettings('tema', value ? 'Dark' : 'Light');
              }),
              _buildToggle('Vibració', isVibrationEnabled, (value) {
                setState(() {
                  isVibrationEnabled = value;
                });
                _updateSettings('vibracio', value);
              }),
              const SizedBox(height: 16),
              _buildSectionTitle('Notificacions'),
              TextButton(
                onPressed: () async {
                  bool? confirmExit = await _showExitDialog(context);
                  if (confirmExit == true) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                    SystemNavigator.pop();
                  }
                },
                child: Text(
                  'Sortir (logout)',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.red[300] : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkTheme ? Colors.grey[900] : Colors.white, // Canvia el fons segons el tema
          title: Text(
            'Vols sortir?',
            style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          ),
          content: Text(
            'Estàs segur que vols tancar l\'aplicació?',
            style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No sortir
              },
              child: Text(
                'No',
                style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Sortir
              },
              child: Text(
                'Sí',
                style: TextStyle(color: isDarkTheme ? Colors.red[300] : Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// **Construeix un títol de secció**
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isDarkTheme ? Colors.white : Colors.black, // Text segons el tema
        ),
      ),
    );
  }

  /// **Construeix un commutador (toggle)**
  Widget _buildToggle(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
      ),
      value: value,
      activeColor: isDarkTheme ? Colors.blue[200] : Colors.blue,
      onChanged: onChanged,
    );
  }
}
