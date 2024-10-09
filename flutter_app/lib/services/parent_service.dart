import 'dart:convert';
import 'dart:math';
import 'package:flutter_app/models/eleve_model.dart';
import 'package:flutter_app/models/jetons_transactions_model.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../exception/api_exception.dart';
import 'auth_service.dart';


class ParentService {
  final AuthService _authService = AuthService();
  final apiAuthority = AppConfig.getApiAuthority();
  final isSecure = AppConfig.isSecure();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


  Future<Map<String, dynamic>> attributeJetonsToChild({
    required int parentId,
    required int childId,
    required int amount,
  }) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/jeton-transaction/transfer')
        : Uri.http(apiAuthority, '/api/jeton-transaction/transfer');


    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'parent_id': parentId,
        'child_id': childId,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'message': responseData['message'],
        'parentNewBalance': responseData['parent_new_balance'],
        'childNewBalance': responseData['child_new_balance'],
      };
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to attribute jetons: ${errorData['error']}');
    }
  }

  Future<List<EleveModel>> getChildrenForParent(int parentId) async {
    try {
      final headers = await _getHeaders();
      final url = isSecure
          ? Uri.https(apiAuthority, '/api/parents/$parentId/children')
          : Uri.http(apiAuthority, '/api/parents/$parentId/children');

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> childrenJson = json.decode(response.body);
        List<EleveModel> children = childrenJson.map((childJson) => EleveModel.fromJson(childJson)).toList();

        // Récupérer les détails pour chaque enfant
        List<EleveModel> detailedChildren = await Future.wait(
            children.where((child) => child.id != null).map((child) => getChildDetails(child.id!))
        );

        return detailedChildren;
      } else {
        throw Exception('Failed to load children');
      }
    } catch (e, stackTrace) {
      print('Erreur lors de la récupération des enfants: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<EleveModel> getChildDetails(int childId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/children/$childId')
        : Uri.http(apiAuthority, '/api/children/$childId');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> childJson = json.decode(response.body);
      return EleveModel.fromJson(childJson);
    } else {
      throw Exception('Failed to load child details');
    }
  }

  // Méthode pour récupérer les interactions d'un enfant
  Future<List<JetonsTransactionModel>> getChildInteractions(int childId) async {

    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/children/$childId/interactions')
        : Uri.http(apiAuthority, '/api/children/$childId/interactions');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> transactionsJson = json.decode(response.body);
      return transactionsJson.map((json) => JetonsTransactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load child transactions');
    }
  }

  // Méthode pour récupérer toutes les interactions des enfants d'un parent
  Future<List<JetonsTransactionModel>> getAllChildrenInteractionsForParent(int parentId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/parents/$parentId/children/interactions')
        : Uri.http(apiAuthority, '/api/parents/$parentId/children/interactions');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> interactionsJson = json.decode(response.body);
      return interactionsJson.map((json) => JetonsTransactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load children interactions');
    }
  }

   Future<List<EleveModel>> getStudentsParentsUsers() async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/users/parents/students')
        : Uri.http(apiAuthority, '/api/users/parents/students');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> elevesJson = json.decode(response.body);
      return elevesJson.map((json) => EleveModel.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des données');
    }
  }

}