import 'package:flutter/material.dart';

import '../../../services/lot_service.dart';

class DeleteLotDialog extends StatelessWidget {
  final int? lotId;
  final String lotName;
  final LotService _lotService = LotService();

  DeleteLotDialog({ this.lotId, required this.lotName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Supprimer le lot'),
      content: Text('Êtes-vous sûr de vouloir supprimer le lot "$lotName" ?'),
      actions: <Widget>[
        TextButton(
          child: Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text('Supprimer'),
          onPressed: () async {
            try {
              final isDeleted = await _lotService.deleteLot(lotId);
              Navigator.of(context).pop(isDeleted);
              if (isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Le lot a été supprimé avec succès')),
                );
              }
            } catch (e) {
              Navigator.of(context).pop(false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur lors de la suppression du lot: ${e.toString()}')),
              );
            }
          },
        ),
      ],
    );
  }
}