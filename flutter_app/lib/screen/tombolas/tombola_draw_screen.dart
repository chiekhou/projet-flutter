import 'package:flutter/material.dart';
import 'package:flutter_app/models/gagnant_model.dart';

import '../../services/tombola_service.dart';


class TombolaDrawScreen extends StatefulWidget {
  final int tombolaId;

  TombolaDrawScreen({required this.tombolaId});

  @override
  _TombolaDrawScreenState createState() => _TombolaDrawScreenState();
}

class _TombolaDrawScreenState extends State<TombolaDrawScreen> {
  final TombolaService _tombolaService = TombolaService();
  bool _isLoading = false;
  List<GagnantModel>? _winners;

  Future<void> _performDraw() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final winners = await _tombolaService.performDraw(widget.tombolaId);
      setState(() {
        _winners = winners;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du tirage: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tirage de la Tombola')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _winners == null
            ? ElevatedButton(
          child: Text('Effectuer le tirage'),
          onPressed: _performDraw,
        )
            : _winners!.isEmpty
            ? Text('Aucun gagnant n\'a été sélectionné dans le tirage.')
            : ListView.builder(
          itemCount: _winners!.length,
          itemBuilder: (context, index) {
            final winner = _winners![index];
            return ListTile(
              title: Text('Gagnant ${index + 1}'),
              subtitle: Text('User ID: ${winner.userId}, Ticket ID: ${winner.ticketId}, Lot ID: ${winner.lotId}'),
            );
          },
        ),
      ),
    );
  }
}