import 'package:flutter/material.dart';
import 'package:flutter_app/services/tombola_service.dart';
import 'package:provider/provider.dart';
import '../../models/ticket_model.dart';
import '../../models/tombola_model.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';


class TombolaDetailScreen extends StatefulWidget {
  final int? tombolaId;
  final Tombola tombola;

  TombolaDetailScreen({required this.tombolaId, required this.tombola});

  @override
  _TombolaDetailScreenState createState() => _TombolaDetailScreenState();
}

class _TombolaDetailScreenState extends State<TombolaDetailScreen> {
  late Future<void> _initFuture;
  final TombolaService _tombolaService = TombolaService();
  final TicketService _ticketService = TicketService();
  List<Ticket> userTickets = [];
  int ticketCount = 0;
  bool isLoading = true;
  int? userId;
  late Tombola currentTombola;

  @override
  void initState() {
    super.initState();
    currentTombola = widget.tombola;
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.fetchUserDetails();
    setState(() {
      userId = authService.userId;
    });
    if (userId != null) {
      await Future.wait([
        _loadUserTickets(),
        _refreshTombolaDetails(),
      ]);
    } else {
      print('Error: User ID is null after fetching user details');
    }
  }

  Future<void> _refreshTombolaDetails() async {
    try {
      final updatedTombola = await _tombolaService.getTombola(widget.tombolaId);
      setState(() {
        currentTombola = updatedTombola;
      });
    } catch (e) {
      print('Error refreshing tombola details: $e');
    }
  }

  Future<void> _loadUserTickets() async {
    if (userId == null) {
      print('Error: User ID is null');
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _ticketService.getUserTickets(widget.tombolaId!, userId!);
      setState(() {
        userTickets = result['tickets'];
        ticketCount = result['count'];
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user tickets: $e');
      setState(() {
        isLoading = false;
        userTickets = [];
        ticketCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des tickets')),
      );
    }
  }

  Future<void> _buyTicket() async {
    if (userId == null) {
      print('Error: Cannot buy ticket, user ID is null');
      return;
    }
    try {
      final result = await _tombolaService.buyTicket(widget.tombolaId!, userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      await Future.wait([
        _loadUserTickets(),
        _refreshTombolaDetails(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'achat du ticket: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTombola.nom),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur lors du chargement des données'));
          }
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    if (userId == null) {
      return Center(child: Text('Erreur: Utilisateur non connecté'));
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple[100]!, Colors.purple[300]!],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.purple[200],
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.card_giftcard, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    currentTombola.nom,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails de la tombola:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Nombre de lots: ${currentTombola.lots?.length ?? 0}'),
                      Text('Tickets vendus: ${currentTombola.tickets?.length ?? 0}'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                child: Text('Acheter un ticket'),
                onPressed: _buyTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lots disponibles:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ...currentTombola.lots?.map((lot) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('• ${lot.nom} - ${lot.valeur}€'),
                      )).toList() ?? [Text('Aucun lot disponible')],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vos tickets:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Nombre de tickets: $ticketCount'),
                      SizedBox(height: 10),
                      isLoading
                          ? CircularProgressIndicator()
                          : userTickets.isEmpty
                          ? Text('Vous n\'avez pas encore de ticket pour cette tombola.')
                          : Column(
                        children: userTickets.map((ticket) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text('Ticket #${ticket.numero}'),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}