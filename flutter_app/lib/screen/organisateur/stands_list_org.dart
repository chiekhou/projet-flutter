import 'package:flutter/material.dart';

import '../../models/stand_model.dart';
import '../../services/stand_service.dart';


class StandsListOrganisateurWidget extends StatefulWidget {
  const StandsListOrganisateurWidget({Key? key}) : super(key: key);

  @override
  _StandsListWidgetState createState() => _StandsListWidgetState();
}

class _StandsListWidgetState extends State<StandsListOrganisateurWidget> {
  late Future<List<Stand>> _standsFuture;
  final StandService _standsService = StandService();

  @override
  void initState() {
    super.initState();
    _standsFuture = _standsService.getStands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Stands'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[300]!, Colors.orange[700]!],
          ),
        ),
        child: FutureBuilder<List<Stand>>(
          future: _standsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            } else if (snapshot.hasData) {
              final stands = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: stands.length,
                itemBuilder: (context, index) {
                  final stand = stands[index];
                  return _buildStandCard(stand);
                },
              );
            } else {
              return const Center(child: Text('Aucun stand disponible', style: TextStyle(color: Colors.white)));
            }
          },
        ),
      ),
    );
  }

  Widget _buildStandCard(Stand stand) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stand.nom,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Type: ${stand.typeString}'),
            const SizedBox(height: 8),
            Text('Stocks:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...?stand.stocks?.map((stock) => Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('Produit: ${stock.nomProduit} -- Quantité: ${stock.quantity}'),
            )),
            const SizedBox(height: 8),
            Text('Jetons dépensés: ${stand.jetonsCollectes}'),
            Text('Points attribués: ${stand.pointsAttribues}'),
          ],
        ),
      ),
    );
  }
}