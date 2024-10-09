import 'package:flutter_app/models/ticket_model.dart';
import 'lot_model.dart';

class Organisateur {
  final int? id;
  final int userId;

  Organisateur({
    this.id,
    required this.userId,

  });

  factory  Organisateur.fromJson(Map<String, dynamic> json) {
    return  Organisateur(
      id: json['id'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,

    };
  }
}