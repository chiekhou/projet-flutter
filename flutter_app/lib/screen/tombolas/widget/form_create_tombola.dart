import 'package:flutter/material.dart';

import '../../../services/tombola_service.dart';


class CreateTombolaForm extends StatefulWidget {
  final int kermesseId;

  CreateTombolaForm({required this.kermesseId});

  @override
  _CreateTombolaFormState createState() => _CreateTombolaFormState();
}

class _CreateTombolaFormState extends State<CreateTombolaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final TombolaService _tombolaService = TombolaService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newTombola = await _tombolaService.createTombola(
          _nomController.text,
          widget.kermesseId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tombola créée avec succès!')),
        );
        Navigator.pop(context, newTombola);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création de la tombola: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer une Tombola')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom de la Tombola'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom pour la tombola';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Créer la Tombola'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}