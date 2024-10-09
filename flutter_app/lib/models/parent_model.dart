import 'package:flutter_app/models/eleve_model.dart';
import 'package:flutter_app/models/user_model.dart';

class ParentModel {
  final int? id;
  final int? userId;
  final int pointsAccumules;
  User? user;
  final List<EleveModel>? enfants;


  ParentModel({
    this.id,
    this.user,
    this.userId,
    this.enfants,
    required this.pointsAccumules,

  });

  factory ParentModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw FormatException('Les données parent sont nulles');
    }

    print('Parsing Parent: $json');

    // Fonction helper pour récupérer les valeurs de manière insensible à la casse
    T? getValueInsensitive<T>(Map<String, dynamic> map, String key) {
      final lowerCaseKey = key.toLowerCase();
      return map.entries
          .firstWhere(
            (entry) => entry.key.toLowerCase() == lowerCaseKey,
        orElse: () => MapEntry(key, null),
      )
          .value as T?;
    }

    List<EleveModel> enfants = [];
    final enfantsData = getValueInsensitive<List?>(json, 'enfants');
    if (enfantsData != null) {
      enfants = enfantsData
          .map((enfantJson) {
        try {
          return EleveModel.fromJson(enfantJson as Map<String, dynamic>);
        } catch (e) {
          print('Erreur lors de la création d\'un EleveModel: $e');
          return null;
        }
      })
          .where((enfant) => enfant != null)
          .cast<EleveModel>()
          .toList();
    }

    final userData = getValueInsensitive<Map<String, dynamic>?>(json, 'User');
    final parent = ParentModel(
      id: getValueInsensitive<int?>(json, 'id'),
      userId: getValueInsensitive<int?>(json, 'user_id'),
      user: userData != null ? User.fromJson(userData) : null,
      enfants: enfants,
      pointsAccumules: getValueInsensitive<int?>(json, 'PointsAccumules') ?? 0,
    );

    print('Parsed Parent: ${parent.toJson()}');
    return parent;
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user': user?.toJson(),
      'enfants': enfants?.map((e) => e.toJson()).toList(),

    };
  }
}