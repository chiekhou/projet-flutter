import 'package:flutter/material.dart';
import '../../models/user_info_point.dart';
import '../../services/users_points_service.dart';

class UserDetailAndPointsPage extends StatefulWidget {
  final UserInfo user;
  final UserPointsService userPointsService;

  const UserDetailAndPointsPage({
    Key? key,
    required this.user,
    required this.userPointsService,
  }) : super(key: key);

  @override
  _UserDetailAndPointsPageState createState() => _UserDetailAndPointsPageState();
}

class _UserDetailAndPointsPageState extends State<UserDetailAndPointsPage> {
  final TextEditingController _pointsController = TextEditingController();
  late UserInfo _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de ${_user.name}'),
        backgroundColor: Colors.orange[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[300]!, Colors.orange[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user.name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Type: ${_user.type.capitalize()}'),
                      SizedBox(height: 8),
                      Text(
                        'Points cumulés: ${_user.points}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              const Text(
                'Attribuer des points',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de points',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _attributePoints,
                    child: Text('Attribuer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _attributePoints() async {
    final points = int.tryParse(_pointsController.text);
    if (points == null || points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un nombre de points valide')),
      );
      return;
    }

    try {
      final updatedUser = await widget.userPointsService.attributePoints(
        _user.id,
        _user.type,
        points,
        _user.name
      );
      setState(() {
        _user = updatedUser;
      });
      _pointsController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Points attribués avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'attribution des points: $e')),
      );
    }
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}