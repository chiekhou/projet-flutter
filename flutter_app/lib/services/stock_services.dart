import 'dart:convert';
import 'package:flutter_app/models/stock_model.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../exception/api_exception.dart';
import 'auth_service.dart';

class StockServices {
  final apiAuthority = AppConfig.getApiAuthority();
  final isSecure = AppConfig.isSecure();
  final AuthService _authService = AuthService();
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


  Future<List<Stock>> getStocksForStand(int standId) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stands/$standId/stocks')
        : Uri.http(apiAuthority, '/api/stands/$standId/stocks');
    final response = await http.get(
      url,
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> stockJson = json.decode(response.body);
      return stockJson.map((json) => Stock.fromJson(json)).toList();
    } else {
      throw ApiException(response.statusCode, 'Failed to load stocks');
    }
  }

  Future<List<Stock>> getStocks() async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stocks')
        : Uri.http(apiAuthority, '/api/stocks');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> stockJson = json.decode(response.body);
      return stockJson.map((json) => Stock.fromJson(json)).toList();
    } else {
      throw ApiException(response.statusCode, 'Failed to load Stocks');
    }
  }

  Future<Stock> getStock(int id) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stocks/$id')
        : Uri.http(apiAuthority, '/api/stocks/$id');

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return Stock.fromJson(json.decode(response.body));
    } else {
      throw ApiException(response.statusCode, 'Failed to load Stock');
    }
  }

  Future<Stock> createStockStand(Stock stock , int id) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stocks/$id/stocks')
        : Uri.http(apiAuthority, '/api/stocks/$id/stocks');
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(stock.toJson()),
    );
    if (response.statusCode == 201) {
      return Stock.fromJson(json.decode(response.body));
    } else {
      throw ApiException(response.statusCode, 'Failed to create Stock');
    }
  }

  Future<Stock> updateStock(int id, Stock stock) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stocks/$id')
        : Uri.http(apiAuthority, '/api/stocks/$id');
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(stock.toJson()),
    );
    if (response.statusCode == 200) {
      return Stock.fromJson(json.decode(response.body));
    } else {
      throw ApiException(response.statusCode, 'Failed to update stocks');
    }
  }

  Future<void> deleteStock(int id) async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stocks/$id')
        : Uri.http(apiAuthority, '/api/stocks/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 204) {
      throw ApiException(response.statusCode, 'Failed to delete stocks');
    }
  }

  Future<Stock> adjustStock(int stockId, int quantityAdjustment) async {
    final token = await _authService.getToken();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/stocks/$stockId/adjust')
        : Uri.http(apiAuthority, '/api/stocks/$stockId/adjust');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({'quantite': quantityAdjustment,
        'stand_id': stockId,
      }),
    );

    if (response.statusCode == 200) {
      return Stock.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      throw ApiException(400, json.decode(response.body)['error']);
    } else if (response.statusCode == 404) {
      throw ApiException(404, 'Stock not found');
    } else {
      throw ApiException(response.statusCode, 'Failed to adjust stocks');
    }
  }
}