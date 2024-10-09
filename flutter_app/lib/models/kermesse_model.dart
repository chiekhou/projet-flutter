import 'package:flutter_app/models/organisateur_model.dart';
import 'package:flutter_app/models/stand_model.dart';
import 'package:flutter_app/models/user_model.dart';

class Kermesse {
  final int? id;
  final String nom;
  final String? planInteractif;
  final String lieu;
  final DateTime date;
  final List<Stand>? stands;
  final List<User>? users;

  Kermesse({
    required this.id,
    required this.nom,
    required this.date,
    required this.lieu,
    this.planInteractif,
    this.stands = const [],
    this.users = const []
  });

  factory Kermesse.fromJson(Map<String, dynamic> json) {
    return Kermesse(
      id: json['id'],
      nom: json['nom'],
      lieu: json['lieu'],
      planInteractif: json['plan_interactif'],
      date: DateTime.parse(json['date']),
      stands: (json['stands'] as List<dynamic>?)
          ?.map((standJson) => Stand.fromJson(standJson))
          .toList() ?? [],
      users: (json['users'] as List<dynamic>?)
          ?.map((userJson) => User.fromJson(userJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'lieu': lieu,
      'plan_interactif': planInteractif,
      'date': date.toIso8601String(),
      'stands': stands?.map((lot) => lot.toJson()).toList(),
      'users': users?.map((ticket) => ticket.toJson()).toList(),
    };
  }
}