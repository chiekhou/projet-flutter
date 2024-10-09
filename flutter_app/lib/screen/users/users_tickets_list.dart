import 'package:flutter/material.dart';
import 'package:flutter_app/services/ticket_service.dart';

import '../../models/ticket_model.dart';

class UserTicketsWidget extends StatefulWidget {
  final int tombolaId;
  final int userId;

  UserTicketsWidget({required this.tombolaId, required this.userId});

  @override
  _UserTicketsWidgetState createState() => _UserTicketsWidgetState();
}

class _UserTicketsWidgetState extends State<UserTicketsWidget> {
  late Future<Map<String, dynamic>> _ticketsFuture;
  final TicketService ticketService = TicketService();

  @override
  void initState() {
    super.initState();
    _ticketsFuture = ticketService.getUserTickets(widget.tombolaId, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Tickets'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[300]!, Colors.orange[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[50]!, Colors.orange[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _ticketsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!['tickets'].isEmpty) {
              return Center(child: Text('Aucun ticket trouvé.'));
            } else {
              List<Ticket> tickets = snapshot.data!['tickets'];
              int count = snapshot.data!['count'];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Nombre total de tickets: $count',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        return TicketCard(ticket: tickets[index]);
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[200]!, Colors.orange[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            'Ticket #${ticket.id}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text('Prix: ${ticket.prixJetons}'),
              SizedBox(height: 4),
              Text('Statut: ${ticket.estGagnant ? "Gagnant" : "En attente"}'),
            ],
          ),
          trailing: Icon(
            ticket.estGagnant ? Icons.star : Icons.hourglass_empty,
            color: ticket.estGagnant ? Colors.yellow[700] : Colors.grey,
            size: 30,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}