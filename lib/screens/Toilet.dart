import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LavaboInfo extends StatefulWidget {
  final int ubicacioId;

  const LavaboInfo({super.key, required this.ubicacioId});

  @override
  _LavaboInfoState createState() => _LavaboInfoState();
}

class _LavaboInfoState extends State<LavaboInfo> {
  final _supabase = Supabase.instance.client;
  String _descripcio = '';
  int _valoracio = 0;
  String _imatgePath = '';
  bool correctResponse = false;
  int _selectedTab = 0;
  int _lavaboId = 0;

  List<String> _imatgesLavabo = [];
  List<Map<String, dynamic>> _comentaris = [];

  @override
  void initState() {
    super.initState();
    _loadLavaboData();
  }

  Future<void> _loadLavaboData() async {
    try {
      final response = await _supabase
          .from('lavabos')
          .select('id_lavabos, descripcio, valoracio, imatge, creacio_usuari')
          .eq('id_ubicacio', widget.ubicacioId)
          .maybeSingle();

      if (response != null && response.isNotEmpty) {
        final lavaboId = response['id_lavabos'];
        setState(() {
          _lavaboId = lavaboId;
          _descripcio = response['descripcio'] ?? 'Descripció no disponible';
          _valoracio = response['valoracio'] ?? 0;
          _imatgePath = response['imatge'] ?? '';
          correctResponse = true;
        });
        _loadLavaboImatges();
        _loadComentaris();
      } else {
        print('Error en la resposta');
      }
    } catch (e) {
      print('Error carregant dades del lavabo: $e');
    }
  }

  Future<void> _loadLavaboImatges() async {
    try {
      final response = await _supabase
          .from('imatges_lavabos')
          .select('imatge')
          .eq('id_lavabo', _lavaboId);

      if (response != null && response.isNotEmpty) {
        setState(() {
          _imatgesLavabo = response
              .map<String>((item) => item['imatge']?.toString() ?? '')
              .where((path) => path.isNotEmpty)
              .toList();
        });
      }
    } catch (e) {
      print('Error carregant imatges del lavabo: $e');
    }
  }

  Future<void> _loadComentaris() async {
    try {
      final comentarisRaw = await _supabase
          .from('comentaris')
          .select('info_comentari, id_usuari')
          .eq('id_lavabo', _lavaboId);

      if (comentarisRaw == null || comentarisRaw.isEmpty) {
        setState(() {
          _comentaris = [];
        });
        print('Comentaris ${_comentaris}');
        return;
      }

      final usuariIds = comentarisRaw
          .map<String>((c) => c['id_usuari'].toString())
          .toSet()
          .toList();

      final usuarisResponse = await _supabase
          .from('usuari')
          .select('id_usuaris, username, imatge') 
          .inFilter('id_usuaris', usuariIds);

          print('Usuaris ${usuarisResponse}');

      final Map<String, String> idToUsername = {
        for (var u in usuarisResponse)
          u['id_usuaris'].toString(): u['username']?.toString() ?? 'Anònim'
      };
      print(usuarisResponse);

      final List<Map<String, dynamic>> comentarisComplets = comentarisRaw.map((c) {
        final idUsuari = c['id_usuari'].toString();
        return {
          'info_comentari': c['info_comentari'],
          'username': idToUsername[idUsuari] ?? 'Anònim',
        };
      }).toList();

      setState(() {
        _comentaris = comentarisComplets;
      });
    } catch (e) {
      print('Error carregant comentaris: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informació del lavabo'),
        backgroundColor: const Color.fromARGB(255, 187, 223, 246),
        elevation: 4.0,
        shadowColor: Colors.black.withValues(),
      ),
      body: correctResponse
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _imatgePath,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(76, 92, 92, 92).withValues(),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        alignment: Alignment(-1 + (_selectedTab * 1.0), 1),
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: FractionallySizedBox(
                          widthFactor: 1 / 3,
                          child: Container(
                            height: 3,
                            color: Color.fromARGB(255, 187, 223, 246),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _buildTabButton("Info", 0),
                          _buildTabButton("Fotos", 1),
                          _buildTabButton("Comentaris", 2),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildTabContent()),
              ],
            )
          : const Center(
              child: Text(
                'No s\'ha trobat informació per aquest lavabo.',
                style: TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
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
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _selectedTab == index ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildInfoTab();
      case 1:
        return _buildFotosTab();
      case 2:
        return _buildComentarisTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // Fins que no afegim al Supabase un camp de info extra, posem un base per tots.
  final _mockDescripcio = 'Localitzat al parc de la Plaça Ferran Casablancas, aquest lavabo destaca per la seva amplitud i per disposar d’un espai adaptat per a persones amb mobilitat reduïda.';
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _descripcio,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildEstrellesValoracio(),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descripció:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(
                    _mockDescripcio,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildEstrellesValoracio() {
    double valorRodat = (_valoracio * 2).round() / 2;
    int estrellesCompletes = valorRodat.floor();
    bool mitjaEstrella = valorRodat - estrellesCompletes == 0.5;

    return Row(
      children: [
        for (int i = 0; i < estrellesCompletes; i++)
          const Icon(Icons.star, color: Colors.amber, size: 20),

        if (mitjaEstrella)
          const Icon(Icons.star_half, color: Colors.amber, size: 20),

        const SizedBox(width: 8),

        Text(
          _valoracio.toStringAsFixed(1),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFotosTab() {
    if (_imatgesLavabo.isEmpty) {
      return const Center(child: Text('No hi ha fotos disponibles.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _imatgesLavabo.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final imagePath = _imatgesLavabo[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 4), // sombra hacia la derecha y abajo
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComentarisTab() {  
    if (_comentaris.isEmpty) {
      return const Center(child: Text('Encara no hi ha comentaris.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _comentaris.length,
      itemBuilder: (context, index) {
        final comentari = _comentaris[index];
        final username = comentari['username'] ?? 'Anònim';
        final text = comentari['info_comentari'] ?? '';
        print("user*: " + username);

        return Card(
          color: Colors.grey[100],
          elevation: 4.0,
          shadowColor: Colors.black.withValues(),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.comment, color: Colors.blueGrey),
            title: Text(username,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(text),
          ),
        );
      },
    );
  }
}
