import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../exception/api_exception.dart';
import '../models/kermesse_model.dart';
import '../models/stand_model.dart';
import 'auth_service.dart';

class KermesseService {
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

  Future<List<Kermesse>> getKermesses() async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses')
        : Uri.http(apiAuthority, '/api/kermesses');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> kermesseJson = json.decode(response.body);
      return kermesseJson.map((json) => Kermesse.fromJson(json)).toList();
    } else {
      throw ApiException(response.statusCode, 'Failed to load kermesses');
    }
  }

  Future<Kermesse> getKermesse(int id) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$id')
        : Uri.http(apiAuthority, '/api/kermesses/$id');

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return Kermesse.fromJson(json.decode(response.body));
    } else {
      throw ApiException(response.statusCode, 'Failed to load kermesse');
    }
  }

  Future<Kermesse> createKermesse(Kermesse kermesse) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses')
        : Uri.http(apiAuthority, '/api/kermesses');
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(kermesse.toJson()),
    );
    if (response.statusCode == 201) {
      return Kermesse.fromJson(json.decode(response.body));
    } else {
      throw ApiException(response.statusCode, 'Failed to create kermesse');
    }
  }

  Future<Kermesse> updateKermesse(int id, Kermesse kermesse) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$id')
        : Uri.http(apiAuthority, '/api/kermesses/$id');
    final response = await http.put(
     url,
      headers: headers,
      body: json.encode(kermesse.toJson()),
    );
    if (response.statusCode == 200) {
      return Kermesse.fromJson(json.decode(response.body));
    } else {
      throw ApiException(response.statusCode, 'Failed to update kermesse');
    }
  }

  Future<void> deleteKermesse(int id) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$id')
        : Uri.http(apiAuthority, '/api/kermesses/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 204) {
      throw ApiException(response.statusCode, 'Failed to delete kermesse');
    }
  }

  Future<String> getKermessePlan(int id) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$id/plan')
        : Uri.http(apiAuthority, '/api/kermesses/$id/plan');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return response.body; // Assuming the plan is returned as a string (maybe JSON or base64 encoded image)
    } else {
      throw ApiException(response.statusCode, 'Failed to load kermesse plan');
    }
  }

  Future<List<Stand>> getKermesseStands(int id) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$id/stands')
        : Uri.http(apiAuthority, '/api/kermesses/$id/stands');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> standsJson = json.decode(response.body);
      return standsJson.map((json) => Stand.fromJson(json)).toList();
    } else {
      throw ApiException(response.statusCode, 'Failed to load kermesse stands');
    }
  }
}