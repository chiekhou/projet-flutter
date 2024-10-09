import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../exception/api_exception.dart';
import '../models/stand_model.dart';
import '../models/user_info_point.dart';
import 'auth_service.dart';

class UserPointsService{
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


Future<Map<String, List<UserInfo>>> getUsersForPointsAttribution() async {
  final headers = await _getHeaders();
  final url = isSecure
      ? Uri.https(apiAuthority, '/api/users/for-points-attribution')
      : Uri.http(apiAuthority, '/api/users/for-points-attribution');

  final response = await http.get(
    url,
    headers: headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return {
      'parents': (data['parents'] as List).map((p) => UserInfo.fromJson(p)).toList(),
      'students': (data['students'] as List).map((s) => UserInfo.fromJson(s)).toList(),
    };
  } else {
    throw Exception('Failed to load users');
  }
}

Future<UserInfo> attributePoints(int userId, String userType, int points , String? userName) async {
  final headers = await _getHeaders();
  final url = isSecure
      ? Uri.https(apiAuthority, '/api/stands/points')
      : Uri.http(apiAuthority, '/api/stands/points');

  print('Sending request to: $url');
  print('Headers: $headers');
  print('Body: ${json.encode({
    'points': points,
    'userId': userId,
    'userType': userType,
    'userName' : userName
  })}');

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'points': points,
        'userId': userId,
        'userType': userType,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return UserInfo.fromJson(jsonResponse);
    } else {
      throw HttpException('Failed to attribute points: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error in attributePoints: $e');
    rethrow;
  }
}
}
