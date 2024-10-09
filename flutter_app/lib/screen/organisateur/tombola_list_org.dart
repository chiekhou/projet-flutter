import 'package:flutter/material.dart';

import '../../models/gagnant_model.dart';
import '../../models/lot_model.dart';
import '../../models/ticket_model.dart';
import '../../models/tombola_model.dart';
import '../../services/tombola_service.dart';
import '../../widgets/app_drawer.dart';

class TombolaCard extends StatefulWidget {
  final Tombola tombola;
  final TombolaService tombolaService;

  const TombolaCard({Key? key, required this.tombola, required this.tombolaService}) : super(key: key);

  @override
  _TombolaCardState createState() => _TombolaCardState();
}

class _TombolaCardState extends State<TombolaCard> {
  bool _isDrawing = false;
  List<GagnantModel>? _winners;

  Future<void> _performDraw() async {
    setState(() {
      _isDrawing = true;
    });

    try {
      final response = await widget.tombolaService.performDraw(widget.tombola.id!);

      if (response is List) {
        setState(() {
          _winners = response.map((item) {
            if (item is GagnantModel) {
              return item;
            } else if (item is Map<String, dynamic>) {
              return GagnantModel.fromJson(item as Map<String, dynamic>);
            } else {
              throw Exception('Unexpected item type in response');
            }
          }).toList();
          _isDrawing = false;
        });
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      setState(() {
        _isDrawing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du tirage au sort: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Tombola'),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tombola.nom,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('Description: ${widget.tombola.nom}'),
                    const SizedBox(height: 16),
                    _buildLotsExpansionTile(),
                    const SizedBox(height: 16),
                    _buildTicketsExpansionTile(),
                    const SizedBox(height: 16),
                    _buildDrawSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLotsExpansionTile() {
    return ExpansionTile(
      title: Text('Lots disponible', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        if (widget.tombola.lots!.isEmpty)
          ListTile(title: Text('Aucun lot disponible pour cette tombola.'))
        else
          ...?widget.tombola.lots?.map((lot) => _buildLotItem(lot)),
      ],
    );
  }

  Widget _buildLotItem(Lot lot) {
    return ListTile(
      title: Text(lot.nom, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(lot.description),
      trailing: Text('${lot.valeur} €', style: TextStyle(color: Colors.green)),
    );
  }

  Widget _buildTicketsExpansionTile() {
    return ExpansionTile(
      title: Text('Tickets Achetés', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        if (widget.tombola.tickets!.isEmpty)
          ListTile(title: Text('Aucun ticket acheté pour cette tombola.'))
        else
          ...?widget.tombola.tickets?.map((ticket) => _buildTicketItem(ticket)),
      ],
    );
  }

  Widget _buildTicketItem(Ticket ticket) {
    return ListTile(
      title: Text('Numéro: ${ticket.numero}'),
      subtitle: Text('UserId: ${ticket.userId}'),
      trailing: Text(
        ticket.estGagnant ? 'Gagnant' : 'Non gagnant',
        style: TextStyle(
          color: ticket.estGagnant ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawSection() {
    if (_winners != null && _winners!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Résultats du tirage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._winners!.map((winner) => ListTile(
            title: Text('Gagnant: ${winner.user?.name ?? "Inconnu"}'),
            subtitle: Text('Lot: ${winner.lot?.nom ?? "Inconnu"}'),
          )),
        ],
      );
    }

    return Center(
      child: ElevatedButton(
        onPressed: _isDrawing ? null : _performDraw,
        child: _isDrawing
            ? CircularProgressIndicator()
            : Text('Effectuer le tirage au sort'),
      ),
    );
  }
}