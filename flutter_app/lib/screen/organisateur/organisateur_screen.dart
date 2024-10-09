import 'package:flutter/material.dart';
import 'package:flutter_app/screen/organisateur/stands_list_org.dart';
import 'package:flutter_app/screen/organisateur/tombola_list_org.dart';
import 'package:provider/provider.dart';
import '../../models/tombola_model.dart';
import '../../services/auth_service.dart';
import '../../services/tombola_service.dart';
import '../../widgets/app_drawer.dart';
import 'classement_users.dart';
import 'summary_transaction.dart';
import '../parent/distribute_jetons.dart';
import '../parent/interaction_enfant.dart';


class OrganisateurScreen extends StatefulWidget {

  @override
  _OrganisateurHomePageState createState() => _OrganisateurHomePageState();
}
class _OrganisateurHomePageState extends State<OrganisateurScreen> {
  List<Tombola> tombolas = [];
  late TombolaService tombolaService;

  @override
  void initState() {
    super.initState();
    tombolaService = TombolaService();
    _loadTombolas();
  }

  Future<void> _loadTombolas() async {
     tombolas = await tombolaService.getTombolas();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Organisateur'),
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
                      'Gérez les activités de la kermesse !',
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
              'Visualiser les stands',
              'Stock , jetons dépensés , points attribués',
              Icons.store,
              Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => StandsListOrganisateurWidget())),
            ),
            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Recette globales',
              'Jetons achetés',
              Icons.attach_money,
              Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionSummaryPage())),
            ),

            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Gestion tombolas',
              'Gérer les tirages au sort',
             Icons.card_giftcard, Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => TombolaCard(tombola: tombolas[0], // Ou choisissez la tombola appropriée
                    tombolaService: tombolaService))),
            ),

            SizedBox(height: 10),
            _buildActionCard(
              context,
              'Classement des joueurs',
              'Pour les activités et donner des lots supplémentaire',
              Icons.card_giftcard, Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => UsersTableScreen())),
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

