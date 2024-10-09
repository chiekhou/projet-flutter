import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'auth_service.dart';

class PaymentService {
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

  Future<Map<String, dynamic>> buyJetons({
    required int userId,
    required int amount,
    required int tokenAmount,
    String? paymentMethodId,
  }) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/jeton-transaction/buy')
        : Uri.http(apiAuthority, '/api/jeton-transaction/buy');

    print('Requesting URL: $url'); // Log de l'URL

    final Map<String, dynamic> body = {
      'user_id': userId,
      'amount': amount,
      'token_amount': tokenAmount,
    };

    if (paymentMethodId != null) {
      body['paymentMethodId'] = paymentMethodId;
    }

    print('Request body: $body'); // Log du body

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Échec de l\'achat de jetons: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Erreur lors de l\'achat de jetons: $e');
    }
  }



  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    // Implémentez ici la logique pour vérifier le statut du paiement après 3D Secure
    // Cela nécessitera probablement un nouvel appel à votre API backend
    throw UnimplementedError('Vérification du statut de paiement non implémentée');
  }


}

