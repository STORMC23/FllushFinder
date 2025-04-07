import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LavaboInfo extends StatefulWidget {
  final int lavaboId;

  const LavaboInfo({super.key, required this.lavaboId});

  @override
  _LavaboInfoState createState() => _LavaboInfoState();
}

class _LavaboInfoState extends State<LavaboInfo> {
  final _supabase = Supabase.instance.client;
  String _descripcio = '';
  int _valoracio = 0;
  String _imatgePath = '';
  bool correctResponse = false;

  @override
  void initState() {
    super.initState();
    _loadLavaboData();
  }

  Future<void> _loadLavaboData() async {
    try {
      final response = await _supabase
          .from('lavabos')
          .select('descripcio, valoracio, imatge, creacio_usuari')
          .eq('id_ubicacio', widget.lavaboId)
          .maybeSingle();
      print("*${widget.lavaboId}*");

      if (response != null && response.isNotEmpty) {
        setState(() {
          _descripcio = response['descripcio'] ?? 'Descripció no disponible';
          _valoracio = response['valoracio'] ?? 0;
          _imatgePath = response['imatge'] ?? '';
          correctResponse = true;
        });
      }
      else{
        print('Error en la resposta');
      }
    } catch (e) {
      print('Error carregant dades del lavabo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informació del lavabo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: correctResponse 
          ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(_imatgePath, height: 150),
              const SizedBox(height: 10),
              Text('Descripció: $_descripcio', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow),
                  Text(' $_valoracio valoracions', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {}, child: const Text('Info')),
                  ElevatedButton(onPressed: () {}, child: const Text('Fotos')),
                  ElevatedButton(onPressed: () {}, child: const Text('Comentaris')),
                ],
              ),
            ],
          )
        : const Center(
              child: Text(
                'No s\'ha trobat informació per aquest lavabo.',
                style: TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
            ),
      ),
    );
  }
}
