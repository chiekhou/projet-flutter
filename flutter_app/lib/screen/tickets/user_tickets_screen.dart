import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../services/ticket_service.dart';


class UserTicketsScreen extends StatefulWidget {
  final int tombolaId;
  final int userId;

  UserTicketsScreen({required this.tombolaId, required this.userId});

  @override
  _UserTicketsScreenState createState() => _UserTicketsScreenState();
}

class _UserTicketsScreenState extends State<UserTicketsScreen> {
  final TicketService _ticketService = TicketService();
  late Future<Map<String, dynamic>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _ticketService.getUserTickets(widget.tombolaId, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vos Tickets')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data!['tickets'] as List).isEmpty) {
            return Center(child: Text('Aucun ticket trouvé pour cet utilisateur'));
          } else {
            final tickets = snapshot.data!['tickets'] as List<Ticket>;
            final count = snapshot.data!['count'] as int;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Nombre de tickets: $count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return ListTile(
                        title: Text('Ticket ${ticket.numero}'),
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