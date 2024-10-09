import 'dart:convert';
import 'package:flutter_app/models/transaction_summary_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/models/jetons_transactions_model.dart';
import '../config/config.dart';
import 'auth_service.dart';

class JetonsService {
  final apiAuthority = AppConfig.getApiAuthority();
  final isSecure = AppConfig.isSecure();
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<JetonsTransactionModel> createJetonTransaction({
    required String description,
    required String type,
    required double montant,
    required int userId,
    int? standId,
  }) async {

    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/jeton-transactions')
        : Uri.http(apiAuthority, '/api/jeton-transactions');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'description': description,
        'type': type,
        'montant': montant,
        'userId': userId,
        'standId': standId,
      }),
    );

    if (response.statusCode == 201) {
      return JetonsTransactionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create jeton transaction: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> payWithJetons({
    required int userId,
    required int standId,
    required int quantity,
  }) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/jeton-transactions/pay-with-jetons')
        : Uri.http(apiAuthority, '/api/jeton-transactions/pay-with-jetons');

    final body = jsonEncode(<String, dynamic>{
      'quantity': quantity,
      'stand_id': standId,
      'user_id': userId,

    });

    print('Sending payment request to $url');
    print('Request body: $body');
    print('Headers: $headers');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'message': responseData['message'],
          'newBalance': responseData['new_balance'],
          'totalCost': responseData['total_cost'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to make payment: ${errorData['error'] ?? response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      rethrow;
    }
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

  Future<List<JetonsTransactionModel>> getUserTransactions(int userId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/users/$userId/jeton-transactions')
        : Uri.http(apiAuthority, '/api/users/$userId/jeton-transactions');


    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> transactionsJson = jsonDecode(response.body);
      return transactionsJson.map((json) => JetonsTransactionModel.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // Si aucune transaction n'est trouvée, retournez une liste vide
      return [];
    } else {
      throw Exception('Failed to load transactions: ${response.body}');
    }
  }

  Future<List<JetonsTransactionModel>> getStandTransactions(int standId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stands/$standId/jeton-transactions')
        : Uri.http(apiAuthority, '/api/stands/$standId/jeton-transactions');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> transactionsJson = jsonDecode(response.body);
      return transactionsJson.map((json) => JetonsTransactionModel.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // Si aucune transaction n'est trouvée, retournez une liste vide
      return [];
    } else {
      throw Exception('Failed to load stand transactions: ${response.body}');
    }
  }

  Future<TransactionSummary> getTransactionSummary() async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/jeton-transactions/summary')
        : Uri.http(apiAuthority, '/api/jeton-transactions/summary');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return TransactionSummary.fromJson(data);
    } else {
      throw Exception('Failed to load transaction summary: ${response.body}');
    }
  }

}

