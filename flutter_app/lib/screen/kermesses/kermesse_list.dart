import 'package:flutter/material.dart';
import '../../models/kermesse_model.dart';
import '../../services/kermesse_service.dart';
import '../../widgets/app_drawer.dart';
import 'kermesse_details.dart';


class KermesseListScreen extends StatefulWidget {
  const KermesseListScreen({super.key});

  @override
  _KermesseListScreenState createState() => _KermesseListScreenState();
}

class _KermesseListScreenState extends State<KermesseListScreen> {
  final KermesseService _kermesseService = KermesseService();
  late Future<List<Kermesse>> _kermessesFuture;

  @override
  void initState() {
    super.initState();
    _kermessesFuture = _kermesseService.getKermesses();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos Kermesses de l\'École'),
        backgroundColor: Colors.orange,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[100]!, Colors.orange[300]!],
          ),
        ),
        child: FutureBuilder<List<Kermesse>>(
          future: _kermessesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune kermesse disponible'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length + 1,  // +1 pour la carte statique
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Carte de bienvenue statique en première position
                    return const Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Bienvenue à la Kermesse!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Rejoignez-nous pour une journée remplie de jeux, de nourriture et de plaisir!',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Index décalé de 1 pour récupérer les kermesses après la carte statique
                    final kermesse = snapshot.data![index - 1];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.celebration, color: Colors.white),
                        ),
                        title: Text(
                          kermesse.nom,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('Date: ${kermesse.date.toString().split(' ')[0]}'),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KermesseDetailScreen(kermesse: kermesse),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}