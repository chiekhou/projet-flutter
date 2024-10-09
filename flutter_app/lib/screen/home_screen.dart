import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kermesse de l\'École'),
        backgroundColor: Colors.orange,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.yellow[100] ?? Colors.yellow,  // Utilise Colors.yellow si null
              Colors.orange[200] ?? Colors.orange,  // Utilise Colors.orange si null
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Bienvenue à la Kermesse!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
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
            ),
            SizedBox(height: 20),
            _buildEventCard('Tombola', 'Gagnez des prix incroyables!', Icons.card_giftcard, Colors.purple),
            _buildEventCard('Stands de Jeux', 'Testez vos compétences!', Icons.games, Colors.blue),
            _buildEventCard('Nourriture', 'Dégustez des délices!', Icons.fastfood, Colors.green),
            _buildEventCard('Spectacles', 'Profitez des performances!', Icons.theater_comedy, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigation vers la page spécifique de l'événement
        },
      ),
    );
  }
}