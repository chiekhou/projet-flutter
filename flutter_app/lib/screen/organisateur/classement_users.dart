import 'package:flutter/material.dart';
import 'package:flutter_app/models/eleve_model.dart';
import 'package:flutter_app/services/parent_service.dart';

import '../../widgets/app_drawer.dart';


class UsersTableScreen extends StatefulWidget {
  @override
  _UsersTableScreenState createState() => _UsersTableScreenState();
}

class _UsersTableScreenState extends State<UsersTableScreen> {
  List<EleveModel> eleves = [];
  bool isLoading = true;
  final ParentService _parentService = ParentService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final loadedEleves = await _parentService.getStudentsParentsUsers();
      setState(() {
        eleves = loadedEleves;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Élèves et Parents'),
        backgroundColor: Colors.orange,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.yellow[100] ?? Colors.yellow,
              Colors.orange[200] ?? Colors.orange,
            ],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Tableau des Élèves et Parents',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Voici la liste de tous les élèves avec leurs parents et informations détaillées.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Élève')),
                    DataColumn(label: Text('Email Élève')),
                    DataColumn(label: Text('Points Élève')),
                    DataColumn(label: Text('Parent')),
                    DataColumn(label: Text('Email Parent')),
                    DataColumn(label: Text('Points Parent')),
                  ],
                  rows: eleves.map((eleve) => DataRow(
                    cells: [
                      DataCell(Text(eleve.user!.name!)),
                      DataCell(Text(eleve.user!.email!)),
                      DataCell(Text(eleve.pointsAccumules.toString())),
                      DataCell(Text(eleve.parent!.user!.name!)),
                      DataCell(Text(eleve.parent!.user!.email!)),
                      DataCell(Text(eleve.parent!.pointsAccumules.toString())),
                    ],
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}