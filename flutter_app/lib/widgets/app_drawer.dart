import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userRole = authService.user?.role;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.yellow[100]!, Colors.orange[200]!],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Kemermess Party',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    authService.user?.name ?? 'Invité',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.deepOrange),
              title: Text('Accueil'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/kermesses');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.deepOrange),
              title: Text('Profil'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            if (userRole == 'TENEUR_STAND')
              ListTile(
                leading: Icon(Icons.card_giftcard, color: Colors.deepOrange),
                title: Text('Gestion Stocks'),
                onTap: () {
                  Navigator.pushNamed(context, '/stocks');
                },
              ),
            if (userRole == 'TENEUR_STAND' || userRole == 'ORGANISATEUR')
              ListTile(
                leading: Icon(Icons.card_giftcard, color: Colors.deepOrange),
                title: Text('Chat'),
                onTap: () {
                  final auth = Provider.of<AuthService>(context, listen: false);
                  if (auth.isLoggedIn && auth.userId != null) {
                    Navigator.pushNamed(context,
                      '/chat',
                      arguments: {'otherUserId': 2},
                    );
                  } else {
                    // Gérez le cas où l'utilisateur n'est pas connecté
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please log in to start a chat')),
                    );
                  }
                }
              ),

            if (userRole == 'PARENT')
              ListTile(
                leading: Icon(Icons.card_giftcard, color: Colors.deepOrange),
                title: Text('Mes enfants'),
                onTap: () {
                  Navigator.pushNamed(context, '/parent');
                },
              ),
            if (userRole == 'PARENT' || userRole == 'ORGANISATEUR')
              ListTile(
                leading: Icon(Icons.confirmation_num, color: Colors.deepOrange),
                title: Text('Mes tickets'),
                onTap: () {
                  Navigator.pushNamed(context, '/parent');
                },
              ),

            if (userRole == 'ORGANISATEUR')
              ListTile(
                leading: Icon(Icons.event, color: Colors.deepOrange),
                title: Text('Gestion des kermesses'),
                onTap: () {
                  Navigator.pushNamed(context, '/organisateur');
                },
              ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.deepOrange),
              title: Text('Déconnexion'),
              onTap: () async {
                await authService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}