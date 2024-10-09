import 'dart:convert';
import 'dart:math';
import 'package:flutter_app/models/gagnant_model.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../exception/api_exception.dart';
import '../models/ticket_model.dart';
import '../models/tombola_model.dart';
import 'auth_service.dart';


class TombolaService {
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

  Future<List<Tombola>> getTombolasForKermesse(int? kermesseId) async {
    if (kermesseId == null) {
      throw ArgumentError('L\'ID de la kermesse ne peut pas être null');
    }
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$kermesseId/tombolas')
        : Uri.http(apiAuthority, '/api/kermesses/$kermesseId/tombolas');
    final response = await http.get(
      url,
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> tombolaJson = json.decode(response.body);
      return tombolaJson.map((json) => Tombola.fromJson(json)).toList();
    } else {
      throw ApiException(response.statusCode, 'Failed to load tombolas');
    }
  }

  Future<Tombola> createTombola(String nom, int kermesseId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$kermesseId/tombolas')
        : Uri.http(apiAuthority, '/api/kermesses/$kermesseId/tombolas');
    final body = json.encode({
      'nom': nom,
      'kermesseId': kermesseId,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Tombola.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        throw ApiException(response.statusCode, errorData['error'] ?? 'Failed to create tombola');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while creating the tombola: ${e.toString()}');
    }
  }

  Future<Tombola> getTombola(int? id) async {
    if (id == null) {
      throw ArgumentError('L\'ID de la kermesse ne peut pas être null');
    }
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/$id')
        : Uri.http(apiAuthority, '/api/tombolas/$id');

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');

        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          return Tombola.fromJson(jsonResponse);
        } catch (e, stackTrace) {
          print('Error decoding JSON: $e');
          print('Stack trace: $stackTrace');
          throw Exception('Failed to decode tombola data: $e');
        }
      } else {
        throw Exception('Failed to load tombola');
      }
    }

  Future<List<Tombola>> getTombolas() async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas')
        : Uri.http(apiAuthority, '/api/tombolas');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> tombolasJson = json.decode(response.body);
      return tombolasJson.map((json) => Tombola.fromJson(json)).toList();
    } else {
      throw ApiException(response.statusCode, 'Failed to load Tombolas');
    }
  }

  String generateTicketNumber() {
    // Préfixe pour indiquer que c'est un ticket
    const prefix = "T-";

    // Récupère l'horodatage actuel en nanosecondes
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();

    // Génère une portion aléatoire (un nombre aléatoire de 4 chiffres)
    final random = Random();
    final randomNumber = random.nextInt(9000) + 1000; // Génère un nombre entre 1000 et 9999

    // Retourne le numéro de ticket sous la forme "T-<timestamp>-<randomNumber>"
    return '$prefix$timestamp-$randomNumber';
  }

  Future<Map<String, dynamic>> buyTicket(int? tombolaId, int userId) async {
    if (tombolaId == null) {
      throw ArgumentError('L\'ID de la kermesse ne peut pas être null');
    }
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/$tombolaId/tickets')
        : Uri.http(apiAuthority, '/api/tombolas/$tombolaId/tickets');
    final body = json.encode({
      'user_id': userId,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'message': responseData['message'],
          'ticket': Ticket.fromJson(responseData['ticket']),
          'newBalance': responseData['new_balance'],
        };
      } else {
        final errorData = json.decode(response.body);
        throw ApiException(response.statusCode, errorData['error'] ?? 'Failed to buy ticket');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while buying the ticket: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getAllTickets() async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/tickets')
        : Uri.http(apiAuthority, '/api/tombolas/tickets');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> ticketsJson = responseData['tickets'];
        final tickets = ticketsJson.map((json) => Ticket.fromJson(json)).toList();
        final totalCount = responseData['totalCount'];

        return {
          'tickets': tickets,
          'totalCount': totalCount,
        };
      } else {
        final errorData = json.decode(response.body);
        throw ApiException(response.statusCode, errorData['error'] ?? 'Failed to get tickets');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while getting tickets: ${e.toString()}');
    }
  }
  Future<List<Tombola>> getKermesseTombolas(int kermesseId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/kermesses/$kermesseId/tombolas')
        : Uri.http(apiAuthority, '/api/kermesses/$kermesseId/tombolas');
    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> tombolasJson = json.decode(response.body);
        return tombolasJson.map((json) => Tombola.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw ApiException(404, 'No tombolas found for this kermesse');
      } else {
        final errorData = json.decode(response.body);
        throw ApiException(response.statusCode, errorData['error'] ?? 'Failed to get kermesse tombolas');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while getting kermesse tombolas: ${e.toString()}');
    }
  }

  Future<List<GagnantModel>> performDraw(int tombolaId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/$tombolaId/draw')
        : Uri.http(apiAuthority, '/api/tombolas/$tombolaId/draw');

    try {
      final response = await http.post(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> winnersJson = responseData['winners'];
        return winnersJson.map((json) => GagnantModel.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw ApiException(response.statusCode, errorData['error'] ?? 'Failed to perform draw');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while performing the draw: ${e.toString()}');
    }
  }

}