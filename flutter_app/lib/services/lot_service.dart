import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../exception/api_exception.dart';
import '../models/lot_model.dart';
import 'auth_service.dart';

class LotService {
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



  Future<Lot> createLot(int tombolaId, Lot lot) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/$tombolaId/lots')
        : Uri.http(apiAuthority, '/api/tombolas/$tombolaId/lots');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(lot.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Lot.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        throw ApiException(response.statusCode, errorData['error'] ?? 'Failed to create lot');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while creating the lot: ${e.toString()}');
    }
  }

  Future<List<Lot>> getLots(int tombolaId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/$tombolaId/lots')
        : Uri.http(apiAuthority, '/api/tombolas/$tombolaId/lots');

    try {
      final response = await http.get(
       url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> lotsJson = json.decode(response.body);
        return lotsJson.map((json) => Lot.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw ApiException(404, 'No lots found for this tombola');
      } else {
        throw ApiException(response.statusCode, 'Failed to retrieve lots');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while getting lots: ${e.toString()}');
    }
  }


  Future<Lot> updateLot(int? lotId, Lot updatedLot) async {
    if (lotId == null) {
      throw ArgumentError('L\'ID du lot ne peut pas être null');
    }
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/lots/$lotId')
        : Uri.http(apiAuthority, '/api/tombolas/lots/$lotId');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(updatedLot.toJson()),
      );

      if (response.statusCode == 200) {
        final lotJson = json.decode(response.body);
        return Lot.fromJson(lotJson);
      } else if (response.statusCode == 404) {
        throw ApiException(404, 'Lot not found');
      } else {
        throw ApiException(response.statusCode, 'Failed to update lot');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while updating the lot: ${e.toString()}');
    }
  }

  Future<bool> deleteLot(int? lotId) async {
    if (lotId == null) {
      throw ArgumentError('L\'ID du lot ne peut pas être null');
    }
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/lots/$lotId')
        : Uri.http(apiAuthority, '/api/tombolas/lots/$lotId');

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] as bool;
      } else {
        throw ApiException(response.statusCode, 'Failed to delete lot');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while deleting the lot: ${e.toString()}');
    }
  }

}