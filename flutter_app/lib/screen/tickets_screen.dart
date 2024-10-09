import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class TicketsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    // Liste fictive de tickets
    final tickets = [
      {'id': '1', 'type': 'Tombola', 'numero': 'T-12345'},
      {'id': '2', 'type': 'Manège', 'numero': 'M-67890'},
      {'id': '3', 'type': 'Restauration', 'numero': 'R-24680'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Tickets'),
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
        child: tickets.isEmpty
            ? const Center(
          child: Text(
            'Vous n\'avez pas encore de tickets',
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    ticket['type']?.substring(0, 1) ?? '',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(ticket['type'] as String? ?? 'Type inconnu'),
                subtitle: Text('Numéro: ${ticket['numero'] as String? ?? 'N/A'}'),
                trailing: Icon(Icons.qr_code, color: Colors.orange),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Détails du ticket ${ticket['numero'] as String? ?? 'N/A'}')),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Acheter de nouveaux tickets')),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}