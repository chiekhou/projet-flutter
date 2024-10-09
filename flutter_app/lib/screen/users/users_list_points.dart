import 'package:flutter/material.dart';
import 'package:flutter_app/screen/users/user_details_point.dart';

import '../../models/user_info_point.dart';
import '../../services/users_points_service.dart';


class UserInfoDisplayPage extends StatelessWidget {
  final UserPointsService userPointsService;
  final int standId;

  const UserInfoDisplayPage({Key? key, required this.userPointsService,required this.standId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informations Utilisateurs'),
        backgroundColor: Colors.orange[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[300]!, Colors.orange[100]!],
          ),
        ),
        child: FutureBuilder<Map<String, List<UserInfo>>>(
          future: userPointsService.getUsersForPointsAttribution(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.orange[700]));
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}', style: TextStyle(color: Colors.red[700])));
            } else if (!snapshot.hasData || (snapshot.data!['parents']!.isEmpty && snapshot.data!['students']!.isEmpty)) {
              return Center(child: Text('Aucun utilisateur trouvé', style: TextStyle(color: Colors.orange[700])));
            }

            final allUsers = [...snapshot.data!['parents']!, ...snapshot.data!['students']!];

            return ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: user.type == 'parent' ? Colors.blue[200] : Colors.green[200],
                      child: Icon(
                        user.type == 'parent' ? Icons.person : Icons.school,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('Type: ${user.type}'),
                        Text('Points: ${user.points}'),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.orange[700]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailAndPointsPage(
                            user: user,
                            userPointsService: userPointsService,

                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}