import 'package:flutter/material.dart';

class Ranking extends StatefulWidget {
  @override
  _RankingState createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  int _selectedTab = 1;

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
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _buildUserTile("Sergi_Voda", "2142p", Icons.emoji_events),
        _buildUserTile("Isa_Vader", "2021p", Icons.emoji_events_outlined),
        _buildUserTile("GutiJedi", "1820p", Icons.emoji_events_outlined),
        _buildUserTile("JoanKenobi", "1419p", Icons.person),
      ],
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
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _buildLocationTile("C. Francesc Macià", 4),
        _buildLocationTile("C. Tres Torres", 5),
      ],
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
