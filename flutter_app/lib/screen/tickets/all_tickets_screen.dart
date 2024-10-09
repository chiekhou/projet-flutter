import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../services/ticket_service.dart';


class AllTicketsScreen extends StatefulWidget {
  @override
  _AllTicketsScreenState createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
  final TicketService _ticketService = TicketService();
  late Future<Map<String, dynamic>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _ticketService.getAllTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tous les Tickets')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Aucun ticket disponible'));
          } else {
            final tickets = snapshot.data!['tickets'] as List<Ticket>;
            final totalCount = snapshot.data!['totalCount'] as int;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Nombre total de tickets: $totalCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return ListTile(
                        title: Text('Ticket ${ticket.numero}'),
                        subtitle: Text('Tombola ID: ${ticket.tombolaId ?? "N/A"}'),
                        trailing: ticket.estGagnant
                            ? Icon(Icons.star, color: Colors.yellow)
                            : null,
                        onTap: () {
                          // Naviguer vers les détails du ticket si nécessaire
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}