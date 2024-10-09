import 'package:flutter/material.dart';

import '../../../models/lot_model.dart';
import '../../../services/lot_service.dart';


class UpdateLotScreen extends StatefulWidget {
  final Lot lot;

  UpdateLotScreen({required this.lot});

  @override
  _UpdateLotScreenState createState() => _UpdateLotScreenState();
}

class _UpdateLotScreenState extends State<UpdateLotScreen> {
  final LotService _lotService = LotService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _valeurController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.lot.nom);
    _descriptionController = TextEditingController(text: widget.lot.description);
    _valeurController = TextEditingController(text: widget.lot.valeur.toString());
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _valeurController.dispose();
    super.dispose();
  }

  Future<void> _updateLot() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedLot = Lot(
          id: widget.lot.id,
          nom: _nomController.text,
          description: _descriptionController.text,
          tombolaId: widget.lot.tombolaId,
          valeur: double.parse(_valeurController.text),
        );

        final result = await _lotService.updateLot(widget.lot.id, updatedLot);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lot mis à jour avec succès')),
        );
        Navigator.pop(context, result);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour du lot: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier le Lot')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom du lot'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom pour le lot';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _valeurController,
                decoration: InputDecoration(labelText: 'Valeur'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une valeur';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateLot,
                child: Text('Mettre à jour le Lot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}