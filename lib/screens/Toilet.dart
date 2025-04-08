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

  @override
  void initState() {
    super.initState();
    _loadLavaboData();
    _loadLavaboImatges();
  }

  Future<void> _loadLavaboData() async {
    try {
      final response = await _supabase
          .from('lavabos')
          .select('id_lavabos, descripcio, valoracio, imatge, creacio_usuari')
          .eq('id_ubicacio', widget.ubicacioId)
          .maybeSingle();

      if (response != null && response.isNotEmpty) {
        setState(() {
          _lavaboId = response['id_lavabos'];
          _descripcio = response['descripcio'] ?? 'Descripció no disponible';
          _valoracio = response['valoracio'] ?? 0;
          _imatgePath = response['imatge'] ?? '';
          correctResponse = true;
        });
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
        print(_lavaboId);
        print('Imatges rebudes: $response');

      if (response != null && response.isNotEmpty) {
        setState(() {
          _imatgesLavabo = response
              .map<String>((item) => item['imatge'])
              .where((path) => path.isNotEmpty)
              .toList();
          print(_imatgesLavabo);
        });
      } else {
        print('No s\'han trobat imatges.');
      }
    } catch (e) {
      print('Error carregant imatges del lavabo: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informació del lavabo'),
      ),
      body: correctResponse
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(_imatgePath, height: 150),
                      const SizedBox(height: 10),
                      Text('Descripció: $_descripcio',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.yellow),
                          Text(' $_valoracio valoracions',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey[300],
                  child: Row(
                    children: [
                      _buildTabButton("Info", 0),
                      _buildTabButton("Fotos", 1),
                      _buildTabButton("Comentaris", 2),
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
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedTab == index ? Colors.white : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return const Center(
          child: Text('Informació adicional (pendent de contingut)',
              style: TextStyle(fontSize: 16)),
        );
      case 1:
        return _buildFotosTab();
      case 2:
        return const Center(
          child: Text('Secció de Comentaris (pendent de contingut)',
              style: TextStyle(fontSize: 16)),
        );
      default:
        return const SizedBox.shrink();
    }
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
          ),
        );
      },
    );
  }
}
