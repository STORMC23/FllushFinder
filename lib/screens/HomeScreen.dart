import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/Configuracio.dart';
import 'package:flutter_application_2/screens/Perfil.dart';
import 'package:flutter_application_2/screens/Ranking.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _searchedLocation;  // Ubicació actual del dispositiu
  LatLng? _searchedQueryLocation; // Ubicació de la cerca
  List<Map<String, dynamic>> _ubicacions = [];
  List<int> _lavaboIds = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUbicacions();
    _getCurrentLocation(); // Obtenir la ubicació actual.
  }

  Future<void> _loadUbicacions() async {
    final client = Supabase.instance.client;
    final responseUbicacions = await client.from('ubicacions').select();
    final responseLavabos = await client.from('lavabos').select('id_ubicacio');

    setState(() {
      _ubicacions = List<Map<String, dynamic>>.from(responseUbicacions);
      _lavaboIds = responseLavabos.map<int>((lavabo) => lavabo['id_ubicacio'] as int).toList();
    });
  }

  Future<void> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied.');
    return;
  }

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  setState(() {
    _searchedLocation = LatLng(position.latitude, position.longitude);
  });

  print("Ubicació actual: Lat: ${position.latitude}, Lon: ${position.longitude}");

  _mapController.move(_searchedLocation!, 15.0);
}


  Widget _buildMarkerLayer() {
    List<Marker> markers = [];

    for (var ubicacio in _ubicacions) {
      bool isLavabo = _lavaboIds.contains(ubicacio['id_ubicacio']);

      if (isLavabo) {
        markers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: LatLng(
              double.parse(ubicacio['latitud'].toString()),
              double.parse(ubicacio['longitud'].toString()),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        );
      }
    }

    if (_searchedLocation != null) {
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: _searchedLocation!,
          child: const Icon(
            Icons.location_on,
            color: Colors.green, 
            size: 40.0,
          ),
        ),
      );
    }

    if (_searchedQueryLocation != null) {
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: _searchedQueryLocation!,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue, // Color blau per la ubicació cercada
            size: 40.0,
          ),
        ),
      );
    }

    return MarkerLayer(markers: markers);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Bathroom Finder'))),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuració'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Rànquing'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(41.3874, 2.1686),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
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
                child: Column(
                  children: [
                    Row(
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
                            onChanged: (query) {
                              if (!_isSearching) {
                                setState(() {
                                  _isSearching = true;
                                });
                              }
                              _searchLocation(query);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_isSearching && _searchResults.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            title: Text(result['nom']),
                            onTap: () {
                              final lat = double.parse(result['latitud'].toString());
                              final lon = double.parse(result['longitud'].toString());

                              setState(() {
                                _searchedQueryLocation = LatLng(lat, lon);
                                _searchController.text = result['nom'] ?? '';
                                _isSearching = false;
                                _searchResults = [];
                              });

                              _mapController.move(_searchedQueryLocation!, 15.0);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 1:
        return UserProfile (userId: widget.userId);
      case 2:
        return SettingsPage(userId: widget.userId);
      case 3:
        return Ranking();
      default:
        return HomeScreen(userId: widget.userId);
    }
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchedQueryLocation = null;
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final results = _ubicacions.where((ubicacio) {
      String nomUbicacio = ubicacio['nom']?.toString() ?? '';
      return nomUbicacio.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }
}
