import 'dart:convert';

import 'package:flutter_app/models/ticket_model.dart';
import 'lot_model.dart';

class Tombola {
  final int? id;
  final String nom;
  final int kermesseId;
  final List<Lot>? lots;
  final List<Ticket>? tickets;

  Tombola({
    this.id,
    required this.nom,
    required this.kermesseId,
    this.lots ,
    this.tickets ,
  });


  factory Tombola.fromJson(Map<String, dynamic> json) {
    return Tombola(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      kermesseId: json['KermesseID'] ?? json['kermesseId'] ?? 0,
      lots: _parseList<Lot>(json['lots'] ?? json['Lots'], Lot.fromJson),
      tickets: _parseList<Ticket>(json['tickets'] ?? json['Tickets'], Ticket.fromJson),
    );
  }

  static List<T> _parseList<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
    if (value is List) {
      return value.map((item) => fromJson(item is String ? json.decode(item) : item)).toList();
    } else if (value is String) {
      try {
        List<dynamic> decodedList = json.decode(value);
        return decodedList.map((item) => fromJson(item)).toList();
      } catch (e) {
        print("Error decoding string to list: $e");
        return [];
      }
    } else {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'KermesseID': kermesseId,
      'Lots': lots?.map((lot) => lot.toJson()).toList(),
      'Tickets': tickets?.map((ticket) => ticket.toJson()).toList(),
    };
  }
}