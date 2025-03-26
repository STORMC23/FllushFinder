import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Ranking extends StatefulWidget {
  @override
  _RankingState createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  final _supabase = Supabase.instance.client;
  int _selectedTab = 1;
  List<dynamic> _users = [];
  List<dynamic> _locations = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchLocations();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await _supabase
          .from('usuari')
          .select('username, punts')
          .order('punts', ascending: false)
          .limit(10);
      setState(() {
        _users = response;
      });
    } catch (e) {
      print('Error obtenint el rànquing d\'usuaris: $e');
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final response = await _supabase
          .from('lavabos')
          .select('descripcio, valoracio')
          .order('valoracio', ascending: false)
          .limit(10);
      setState(() {
        _locations = response;
      });
    } catch (e) {
      print('Error obtenint el rànquing de localitzacions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.grey[300],
            child: Row(
              children: [
                _buildTabButton("Localitzacions", 0),
                _buildTabButton("Usuaris", 1),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0 ? _buildLocationsRanking() : _buildUsersRanking(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedTab == index ? Colors.white : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersRanking() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final icon = index == 0
            ? Icons.emoji_events
            : (index < 3 ? Icons.emoji_events_outlined : Icons.person);
        return _buildUserTile(user['username'], "${user['punts']}p", icon);
      },
    );
  }

  Widget _buildUserTile(String name, String points, IconData icon) {
    return Card(
      color: Colors.grey[200],
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(points),
        ),
      ),
    );
  }

  Widget _buildLocationsRanking() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final location = _locations[index];
        return _buildLocationTile(location['descripcio'], location['valoracio']);
      },
    );
  }

  Widget _buildLocationTile(String name, int stars) {
    return Card(
      color: Colors.grey[200],
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: List.generate(
            stars,
            (index) => const Icon(Icons.emoji_events, color: Colors.brown),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text("23944 Val"),
        ),
      ),
    );
  }
}
