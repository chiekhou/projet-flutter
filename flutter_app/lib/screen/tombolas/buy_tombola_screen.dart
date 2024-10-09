import 'package:flutter/material.dart';
import 'package:flutter_app/services/tombola_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';

class BuyTombolaTicketsScreen extends StatefulWidget {
  late final int tombolaId;
  late final int userId;


  @override
  _BuyTombolaTicketsScreenState createState() => _BuyTombolaTicketsScreenState();
}

class _BuyTombolaTicketsScreenState extends State<BuyTombolaTicketsScreen> {
  int _ticketCount = 0;
  final int _ticketCost = 2;
  final TombolaService _tombolaService = TombolaService();
  bool _isLoading = false;

  void _buyTicket() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _tombolaService.buyTicket(widget.tombolaId, widget.userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket acheté avec succès! Nouveau solde: ${result['newBalance']} jetons')),
      );
      Navigator.pop(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'achat du ticket: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Acheter des Billets de Tombola'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Solde de Jetons: ${user?.soldeJetons ?? 0}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Nombre de billets: $_ticketCount',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Icon(Icons.remove),
                    onPressed: () {
                      if (_ticketCount > 0) {
                        setState(() {
                          _ticketCount--;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _ticketCount++;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Coût total: ${_ticketCount * _ticketCost} jetons',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                child: Text('Acheter les Billets'),
                onPressed: () {
                  // Logique pour acheter les billets
                  if (_ticketCount > 0 && (user?.soldeJetons ?? 0) >= _ticketCount * _ticketCost) {
                    // Appeler une méthode de votre AuthService pour effectuer l'achat
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Achat de $_ticketCount billets réussi')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Solde insuffisant ou aucun billet sélectionné')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}