import 'package:flutter/material.dart';
import 'package:flutter_app/screen/stocks/stocks_list.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/users_points_service.dart';
import '../../widgets/app_drawer.dart';
import '../users/users_list_points.dart';

class GestionStocksAccueil extends StatelessWidget {


  const GestionStocksAccueil({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userPointsService = Provider.of<UserPointsService>(context, listen: false);

    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion Teneur'),
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
                      'Bienvenue, ${user?.name ?? "Teneur de Stand"}!',
                      style: const TextStyle(fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    ),
                    SizedBox(height: 10),
                    const Text(
                      'Gérez les stock de la kermesse et profitez de la kermesse !',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Stocks disponible',
              'Pensez à vérifié votre stock',
              Icons.inventory,
              Colors.purple,
                  () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => StockListScreen())),
            ),

            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Voir les utilisateurs',
              'Vous pouvez attribué des points aux parents et aux éléves',
              Icons.people,
              Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => UserInfoDisplayPage(
                    userPointsService: Provider.of<UserPointsService>(context, listen: false),
                    standId: 4,
                  )
              )),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title,
      String description, IconData icon, Color color, VoidCallback onTap) {
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
                  Text(title, style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
              Text(description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
