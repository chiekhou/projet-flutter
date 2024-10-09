import 'package:flutter_app/models/user_model.dart';

class MessageModel {
  final int? id;
  final bool? lu;
  final String? contenu;
  final int? expediteurId;
  final int? destinataireId;
  final DateTime date;
  final User? expediteur;
  final User? destinataire;


  MessageModel({
    this.id,
    this.lu,
    this.contenu,
    this.expediteurId,
    this.destinataireId,
    required this.date,
    this.expediteur,
    this.destinataire,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int? ?? -1,
      expediteurId: json['expediteur_id'] as int? ?? -1,
      destinataireId: json['destinataire_id'] as int? ?? -1,
      contenu: json['contenu'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      lu: json['lu'] as bool? ?? false,
    );
  }

  // Méthode pour vérifier si le message est valide
  bool isValid() {
    return id != -1 && expediteurId != -1 && destinataireId != -1;

  }

  Map<String, dynamic> toJson() {
    return {
      'contenu': contenu,
      'expediteur_id' : expediteurId,
      'destinataire_id' : destinataireId,
    };
  }
}