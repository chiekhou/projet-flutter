import 'package:flutter/material.dart';

import '../../../models/lot_model.dart';
import '../../../services/lot_service.dart';


class CreateLotScreen extends StatefulWidget {
  final int tombolaId;

  CreateLotScreen({required this.tombolaId});

  @override
  _CreateLotScreenState createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen> {
  final LotService _lotService = LotService();
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valeurController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createLot() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newLot = Lot(
          nom: _nomController.text,
          description: _descriptionController.text,
          valeur: double.parse(_valeurController.text),
        );

        final createdLot = await _lotService.createLot(widget.tombolaId, newLot);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lot créé avec succès')),
        );
        Navigator.pop(context, createdLot);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création du lot: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un Lot')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                decoration: InputDecoration(labelText: 'Description (optionnel)'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _valeurController,
                decoration: InputDecoration(labelText: 'Valeur du lot'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une valeur pour le lot';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createLot,
                child: Text('Créer le Lot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}