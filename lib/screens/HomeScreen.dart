import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Perfil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final MapController _mapController = MapController();
  LatLng? _searchedLocation; // Guardem la ubicació cercada
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(41.3874, 2.1686), // Barcelona
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              // Aquí llamamos a la función que maneja el MarkerLayer
              _buildMarkerLayer(),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cerca una ubicació...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (query) => _searchLocation(query),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                _showFilterDialog();
              },
              child: const Icon(Icons.tune),
              backgroundColor: Colors.blue,
              mini: true,
            ),
          ),
        ],
      ),
      const ProfilePage(),
      const Center(child: Text('Configuració', style: TextStyle(fontSize: 24))),
      const Center(child: Text('Ranking', style: TextStyle(fontSize: 24))),
    ]);
  }

  // Funció de cerca per mostrar el marcador a la nova ubicació
  void _searchLocation(String query) async {
    final results = await _searchLocations(query);
    if (results.isNotEmpty) {
      final location = results.first;
      final lat = double.parse(location['lat'].toString());
      final lon = double.parse(location['lon'].toString());

      // Imprimim les coordenades per veure si tot és correcte
      print('Ubicació trobada: Lat: $lat, Lon: $lon');

      setState(() {
        _searchedLocation = LatLng(lat, lon); // Actualitza la ubicació cercada
        _buildMarkerLayer();
      });

      // Mou el mapa i actualitza la ubicació amb el marcador
      _mapController.move(_searchedLocation!, 15.0); // Mou el mapa a la nova ubicació
    } else {
      print('No es va trobar la ubicació per a: $query');
    }
  }

  // Funció per cercar ubicacions
  Future<List<Map<String, dynamic>>> _searchLocations(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Comprovem què ens retorna l'API
      final List<dynamic> data = json.decode(response.body);
      print('Resultats de la cerca: $data');  // Imprimim el resultat de l'API
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('Error en la resposta de l\'API: ${response.statusCode}');
      return [];
    }
  }

  // Mostra el diàleg amb els filtres
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtres'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOption('Gratuït', Switch(value: true, onChanged: (val) {})),
                _buildFilterOption('Valoració', const Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange),
                    Icon(Icons.star, color: Colors.orange),
                    Icon(Icons.star, color: Colors.orange),
                    Icon(Icons.star_border, color: Colors.orange),
                    Icon(Icons.star_border, color: Colors.orange),
                  ],
                )),
                _buildFilterOption('Distància', const Text('5 km', style: TextStyle(fontSize: 16))),
                _buildFilterOption('Història', Switch(value: false, onChanged: (val) {})),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tancar'),
            ),
          ],
        );
      },
    );
  }

  // Funció auxiliar per construir les opcions de filtre
  Widget _buildFilterOption(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          widget,
        ],
      ),
    );
  }

  // Funció per gestionar el canvi d'ítem seleccionat al BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() { //hola
      _selectedIndex = index;
    });
  }

  // Funció que retorna el MarkerLayer només si hi ha una ubicació cercada
  Widget _buildMarkerLayer() {
    if (_searchedLocation != null) {
      return MarkerLayer(
        markers: [
          Marker(
            width: 40.0,
            height: 40.0,
            point: _searchedLocation!,  // Mostrar la ubicació cercada
            child: const Icon(
              Icons.location_on,
              color: Colors.red, // Marcador vermell
              size: 40.0,
            ),
          ),
        ],
      );
    } else {
      return Container(); // Retorna un contenidor buit si no hi ha ubicació cercada
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Bathroom Finder')),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuració'),
          BottomNavigationBarItem(icon: Icon(Icons.align_vertical_bottom_rounded), label: 'Ranking'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
