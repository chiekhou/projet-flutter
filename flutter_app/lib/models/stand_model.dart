import 'package:flutter_app/extension/extension_type_stand.dart';
import 'package:flutter_app/models/stock_model.dart';
enum StandType { ACTIVITES, NOURRITURE, BOISSON }

class Stand {
  final int? id;
  final String nom;
  final dynamic type;
  final int positionX;
  final int positionY;
  final int? jetonsCollectes;
  final int? pointsAttribues;
  late final List<Stock>? stocks;
  final int? teneurId;
  final int? kermesseId;

  Stand({
    this.id,
    required this.nom,
    required this.type,
    required this.positionX,
    required this.positionY,
    this.stocks ,
    this.jetonsCollectes,
    this.pointsAttribues,
    this.teneurId,
    this.kermesseId,

  });

  Stand copyWith({List<Stock>? stocks}) {
    return Stand(
      id: this.id,
      nom: this.nom,
      type: this.type,
      kermesseId: this.kermesseId,
      teneurId: this.teneurId,
      positionX: this.positionX,
      positionY: this.positionY,
      jetonsCollectes: this.jetonsCollectes,
      pointsAttribues: this.pointsAttribues,
      stocks: stocks ?? this.stocks,
    );
  }

  String get typeString {
    if (type is int) {
      return _intToTypeString(type as int);
    } else if (type is String) {
      return type as String;
    }
    return 'INCONNU';
  }

  static String _intToTypeString(int typeInt) {
    switch (typeInt) {
      case 0:
        return 'NOURRITURE';
      case 1:
        return 'BOISSON';
      case 2:
        return 'ACTIVITE';
      default:
        return 'INCONNU';
    }
  }

  factory Stand.fromJson(Map<String, dynamic> json) {
    print('Parsing Stand: $json');
    return Stand(
      id: json['id'],
      nom: json['nom'],
      type: json['type'],
      positionX: json['position_x'],
      positionY: json['position_y'],
      jetonsCollectes: json['jetons_collectes'],
      pointsAttribues: json['points_attribues'],
      teneurId: json['teneur_id'],
      kermesseId: json['kermesse_id'],
      stocks: (json['Stocks'] as List<dynamic>?)
          ?.map((stockJson) => Stock.fromJson(stockJson))
          .toList()?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'type': type,
      'position_x': positionX,
      'position_y': positionY,
      'jetons_collectes': jetonsCollectes,
      'points_attribues': pointsAttribues,
      'teneur_id': teneurId,
      'kermesse_id': kermesseId,
      'Stocks': stocks?.map((stock) => stock.toJson()).toList(),
    };
  }
}