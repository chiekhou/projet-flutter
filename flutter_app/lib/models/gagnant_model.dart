import 'package:flutter_app/models/ticket_model.dart';
import 'package:flutter_app/models/tombola_model.dart';
import 'package:flutter_app/models/user_model.dart';
import 'lot_model.dart';

class GagnantModel {
  final int id;
  final int? userId;
  final int? tombolaId;
  final int? lotId;
  final int? ticketId;
  final User? user;
  final Tombola? tombola;
  final Lot? lot;
  final Ticket? ticket;

  GagnantModel({
    required this.id,
    this.userId,
    this.tombolaId,
    this.lotId,
    this.ticketId,
    this.user,
    this.tombola,
    this.lot,
    this.ticket,

  });

  factory GagnantModel.fromJson(Map<String, dynamic> json) {
    return GagnantModel(
      id: json['id'] ?? 0, // Provide a default value if null
      userId: json['user_id'],
      tombolaId: json['tombola_id'],
      lotId: json['lot_id'],
      ticketId: json['ticket_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      tombola: json['tombola'] != null ? Tombola.fromJson(json['tombola']) : null,
      lot: json['lot'] != null ? Lot.fromJson(json['lot']) : null,
      ticket: json['ticket'] != null ? Ticket.fromJson(json['ticket']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'tombola_id': tombolaId,
      'lot_id': lotId,
      'ticket_id': ticketId,
      'user': user,
      'tombola': tombola,
      'lot': lot,
      'ticket' : ticket

    };
  }
}