import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/config.dart';
import '../exception/api_exception.dart';
import '../models/kermesse_model.dart';
import '../models/stand_model.dart';
import '../models/stock_model.dart';
import 'auth_service.dart';

class StandService {
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


  Future<List<Stand>> getStandsForKermesse(int? kermesseId) async {
    if (kermesseId == null) {
      throw ArgumentError('L\'ID de la kermesse ne peut pas être null');
    }

    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$kermesseId/stands')
        : Uri.http(apiAuthority, '/api/kermesses/$kermesseId/stands');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Vérifier si le corps de la réponse est null ou vide
        if (response.body == null || response.body.isEmpty) {
          print('Response body is null or empty');
          return [];
        }

        // Décoder le JSON et vérifier s'il s'agit bien d'une liste
        final dynamic decodedJson = json.decode(response.body);
        if (decodedJson is! List) {
          print('Decoded JSON is not a List: $decodedJson');
          return [];
        }

        List<dynamic> standJson = decodedJson;
        return standJson.map((json) {
          try {
            return Stand.fromJson(json);
          } catch (e) {
            print('Error parsing stand: $json');
            print('Error details: $e');
            return null;
          }
        }).where((stand) => stand != null).cast<Stand>().toList();
      } else {
        throw ApiException(response.statusCode, 'Failed to load stands: ${response.body}');
      }
    } catch (e) {
      print('Error in getStandsForKermesse: $e');
      rethrow;
    }
  }

  Future<List<Stand>> getStands() async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stands')
        : Uri.http(apiAuthority, '/api/stands');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> standJson = json.decode(response.body);
      return standJson.map((json) => Stand.fromJson(json)).toList();
    } else {
      throw ApiException(response.statusCode, 'Failed to load Stands');
    }
  }

  Future<Stand> getStand(int? id) async {
    if (id == null) {
      throw ArgumentError('L\'ID du stand ne peut pas être null');
    }
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stands/$id')
        : Uri.http(apiAuthority, '/api/stands/$id');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      Map<String,dynamic> standJson = jsonDecode(response.body);
      return Stand.fromJson(standJson);
    } else {
      throw Exception('Impossible de récupérer les stocks du stand');
    }
  }


  Future<Stand> createStand(Stand stand) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stands')
        : Uri.http(apiAuthority, '/api/stands');
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(stand.toJson()),
    );
    if (response.statusCode == 201) {
      return Stand.fromJson(json.decode(response.body));
    } else {
      throw ApiException(response.statusCode, 'Failed to create Stand');
    }
  }

  Future<Stand> updateStand(int id, Stand stand) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stands/$id')
        : Uri.http(apiAuthority, '/api/stands/$id');
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(stand.toJson()),
    );
    if (response.statusCode == 200) {
      return Stand.fromJson(json.decode(response.body));
    } else {
      throw ApiException(response.statusCode, 'Failed to update stands');
    }
  }

  Future<void> deleteStand(int id) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stands/$id')
        : Uri.http(apiAuthority, '/api/stands/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 204) {
      throw ApiException(response.statusCode, 'Failed to delete stands');
    }
  }
}