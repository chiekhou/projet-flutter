import 'package:flutter/material.dart';
import 'package:flutter_app/models/kermesse_model.dart';
import 'package:flutter_app/screen/home_screen.dart';
import 'package:flutter_app/screen/tombolas/buy_tombola_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';



class EnfantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Élève'),
        backgroundColor: Colors.orange,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.yellow[100]!, Colors.orange[200]!],
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
                      'Bienvenue, ${user?.name ?? "Élève"}!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Profite de la kermesse et amuse-toi bien !',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.confirmation_number, color: Colors.orange, size: 40),
                title: Text('Solde de Jetons', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${user?.soldeJetons ?? 0} jetons disponibles'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            SizedBox(height: 20),
            _buildActionCard(
              context,
              'Interagir avec un Stand',
              'Utilise tes jetons pour profiter des stands !',
              Icons.store,
              Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())),
            ),
            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Acheter des Billets de Tombola',
              'Tente ta chance de gagner des lots incroyables !',
              Icons.card_giftcard,
              Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => BuyTombolaTicketsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 30),
                  SizedBox(width: 10),
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
              Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}