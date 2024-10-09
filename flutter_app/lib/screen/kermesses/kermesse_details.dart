import 'package:flutter/material.dart';
import '../../models/kermesse_model.dart';
import '../../models/stand_model.dart';
import '../../models/tombola_model.dart';
import '../../services/auth_service.dart';
import '../../services/stand_service.dart';
import '../../services/tombola_service.dart';
import '../stands/stand_details_screen.dart';
import '../tombolas/tombola_details.dart';


class KermesseDetailScreen extends StatefulWidget {
  final Kermesse kermesse;

  KermesseDetailScreen({required this.kermesse});

  @override
  _KermesseDetailScreenState createState() => _KermesseDetailScreenState();
}

class _KermesseDetailScreenState extends State<KermesseDetailScreen> {
  final TombolaService _tombolaService = TombolaService();
  final AuthService _auth = AuthService();
  final StandService _standService = StandService();
  late Future<List<Tombola>> _tombolasFuture;
  late Future<List<Stand>> _standsFuture;

  @override
  void initState() {
    super.initState();
    _tombolasFuture =
        _tombolaService.getTombolasForKermesse(widget.kermesse.id);
    _standsFuture = _standService.getStandsForKermesse(widget.kermesse.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kermesse.nom),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[100]!, Colors.orange[300]!],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${widget.kermesse.date.toString().split(' ')[0]}',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    const Text(
                      'Tombolas:',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              _buildTombolasList(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Stands:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _buildStandsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTombolasList() {
    return FutureBuilder<List<Tombola>>(
      future: _tombolasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucune tombola disponible'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tombola = snapshot.data![index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.card_giftcard, color: Colors.purple),
                  title: Text(tombola.nom),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TombolaDetailScreen(tombolaId: tombola.id, tombola: tombola),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildStandsList() {
    return FutureBuilder<List<Stand>>(
      future: _standsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun stand disponible'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final stand = snapshot.data![index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.store, color: Colors.blue),
                  title: Text(stand.nom),
                  subtitle: Text(stand.typeString),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StandDetailScreen(stand: stand, initialStand: stand),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}