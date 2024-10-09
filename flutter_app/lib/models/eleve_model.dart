import 'package:flutter_app/models/parent_model.dart';
import 'package:flutter_app/models/ticket_model.dart';
import 'package:flutter_app/models/user_model.dart';

class EleveModel {
  final int? id;
  final int? pointsAccumules;
  final int? userId;
  final int? parentId;
  User? user;
  final ParentModel? parent;
  final String? createdAt;
  final String? updatedAt;

  EleveModel({
    this.id,
    this.user,
    this.pointsAccumules,
    required this.parent,
    required this.userId,
    required this.parentId,
    this.createdAt,
    this.updatedAt,

  });

  factory  EleveModel.fromJson(Map<String, dynamic> json) {
    print('Creating EleveModel from JSON: $json');
    try {
      return EleveModel(
        id: json['ID'] as int?,
        pointsAccumules: json['PointsAccumules'] as int?,
        userId: json['UserID'] as int?,
        parentId: json['parent_id'] as int?,
        user: json['User'] != null ? User.fromJson(
            json['User'] as Map<String, dynamic>) : null,
        parent: json['Parent'] != null ? ParentModel.fromJson(
            json['Parent'] as Map<String, dynamic>) : null,
        createdAt: json['CreatedAt'] as String?,
        updatedAt: json['UpdatedAt'] as String?,
      );
    } catch (e, stackTrace) {
      print('Error in EleveModel.fromJson: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'UserID': userId,
      'User': user?.toJson(),
      'Parent': parent?.toJson(),
      'ParentID': parentId,
      'PointsAccumules': pointsAccumules

    };
  }
}