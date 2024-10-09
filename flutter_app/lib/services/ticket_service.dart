import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../exception/api_exception.dart';
import '../models/ticket_model.dart';
import 'auth_service.dart';


class TicketService {
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

  Future<Map<String, dynamic>> getUserTickets(int tombolaId, int userId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/tombolas/$tombolaId/user/$userId/tickets')
        : Uri.http(apiAuthority, '/api/tombolas/$tombolaId/user/$userId/tickets');

    print('Fetching tickets from URL: $url');
    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> ticketsJson = responseData['tickets'];
        final tickets = ticketsJson.map((json) => Ticket.fromJson(json)).toList();
        final count = responseData['count'];

        return {
          'tickets': tickets,
          'count': count,
        };
      } else if (response.statusCode == 404) {
        return {
          'tickets': <Ticket>[],
          'count': 0,
        };
      } else {
        final errorData = json.decode(response.body);
        throw ApiException(response.statusCode, errorData['error'] ?? 'Failed to get user tickets');
      }
    } catch (e) {
      throw ApiException(500, 'An error occurred while getting user tickets: ${e.toString()}');
    }
  }
}