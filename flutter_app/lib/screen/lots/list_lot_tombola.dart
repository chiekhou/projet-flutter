import 'package:flutter/material.dart';
import 'package:flutter_app/screen/lots/widgets/delete_lot_widget.dart';
import '../../models/lot_model.dart';
import '../../services/lot_service.dart';

class LotsListScreen extends StatefulWidget {
  final int tombolaId;

  LotsListScreen({required this.tombolaId});

  @override
  _LotsListScreenState createState() => _LotsListScreenState();
}

class _LotsListScreenState extends State<LotsListScreen> {
  final LotService _lotService = LotService();
  late Future<List<Lot>> _lotsFuture;

  @override
  void initState() {
    super.initState();
    _loadLots();
  }

  void _loadLots() {
    _lotsFuture = _lotService.getLots(widget.tombolaId);
  }

  Future<void> _deleteLot(Lot lot) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteLotDialog(lotId: lot.id, lotName: lot.nom),
    );

    if (result == true) {
      setState(() {
        _loadLots(); // Recharger la liste des lots après la suppression
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lots de la Tombola')),
      body: FutureBuilder<List<Lot>>(
        future: _lotsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun lot trouvé pour cette tombola'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final lot = snapshot.data![index];
                return ListTile(
                  title: Text(lot.nom),
                  subtitle: Text('Valeur: ${lot.valeur}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteLot(lot),
                  ),
                  onTap: () {
                    // Naviguer vers les détails du lot si nécessaire
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}