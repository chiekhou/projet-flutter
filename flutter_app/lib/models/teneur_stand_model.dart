import 'package:flutter_app/models/ticket_model.dart';
import 'lot_model.dart';

class TeneurStand {
  final int? id;
  final int userId;

  TeneurStand({
    this.id,
    required this.userId,

  });

  factory  TeneurStand.fromJson(Map<String, dynamic> json) {
    return  TeneurStand(
      id: json['id'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_is': userId,

    };
  }
}