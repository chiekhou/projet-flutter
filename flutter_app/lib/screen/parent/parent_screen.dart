import 'package:flutter/material.dart';
import 'package:flutter_app/screen/parent/register_child.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_drawer.dart';
import 'distribute_jetons.dart';
import 'interaction_enfant.dart';


class ParentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Parent'),
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
                      'Bienvenue, ${user?.name ?? "Parent"}!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    SizedBox(height: 10),
                    const Text(
                      'Gérez les activités de vos enfants et profitez de la kermesse !',
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
                leading: Icon(Icons.account_balance_wallet, color: Colors.green, size: 40),
                title: Text('Solde de Jetons', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${user?.soldeJetons ?? 0} jetons disponibles'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Naviguer vers l'écran de détails du solde si nécessaire
                },
              ),
            ),

            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Distribuer des Jetons',
              'Donnez des jetons à vos enfants',
              Icons.transfer_within_a_station,
              Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => DistributeTokensScreen())),
            ),
            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Ajouter un enfant',
              'Enregistrer votre enfant à partir de votre profil',
              Icons.child_care,
              Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterChildScreen())),
            ),
            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Activités des Enfants',
              'Suivez les interactions de vos enfants',
              Icons.child_care,
              Colors.teal,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewChildrenInteractionsScreen())),
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