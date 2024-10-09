import 'dart:async';
import 'package:flutter_app/models/parent_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/config.dart';


class AuthService with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  ParentModel? _parent;
  User? _user;
  String? _userRole;
  bool get isLoggedIn => _token != null;
  Timer? _authTimer;
  final _storage = FlutterSecureStorage();
  final apiAuthority = AppConfig.getApiAuthority();
  final isSecure = AppConfig.isSecure();
  static const String _tokenKey = 'auth_token';

  bool get isAuth {
    return token != null;
  }

  String? get userRole => _userRole;

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  User? get user {
    return _user;
  }

  int? get userId => _user?.id;

  ParentModel? get parent => _parent;

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchParentInfo() async {
    if (_user == null) return;

    final url = isSecure
        ? Uri.https(apiAuthority, '/api/parents/user/me')
        : Uri.http(apiAuthority, '/api/parents/user/me');

    try {
      final response = await http.get(
        url,
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
      );
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic parentData = json.decode(response.body);
        print('Parent data from API: $parentData');

        if (parentData == null) {
          print('Les données parent sont nulles');
          _parent = null;
          notifyListeners();
          return;
        }

        if (parentData is! Map<String, dynamic>) {
          print('Les données parent ne sont pas au format attendu: ${parentData.runtimeType}');
          throw Exception('Les données parent ne sont pas au format attendu (Map<String, dynamic>)');
        }

        try {
          _parent = ParentModel.fromJson(parentData);
          print('Parsed parent: ${_parent?.toJson()}');
          notifyListeners();
          await _saveAuthData();
          print('Détails utilisateur récupérés avec succès: ${_parent?.toJson()}');
        } catch (e, stackTrace) {
          print('Erreur lors du parsing des données parent: $e');
          print('Stack trace: $stackTrace');
          throw Exception('Erreur lors du parsing des données parent: $e');
        }
      } else {
        print('Failed to fetch parent details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Échec du chargement des données utilisateur. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des détails utilisateur: $error');
      _parent = null;
      notifyListeners();
      throw Exception('Échec du chargement des données utilisateur: $error');
    }
  }


  Future<void> refreshUserInfo() async {
    try {
      // Supposons que vous ayez une méthode pour obtenir les détails de l'utilisateur
      final userData = await fetchUserDetails();
      _user = User.fromJson(userData!); // Assurez-vous que votre classe User a une méthode fromJson
      notifyListeners();
    } catch (e) {
      print('Erreur lors du rafraîchissement des informations utilisateur: $e');
      // Gérez l'erreur comme vous le souhaitez
    }
  }


  Future<void> register(String name, String email, String password,
      String role) async {
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/register')
        : Uri.http(apiAuthority, '/api/register');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'inscription');
      }
    } catch (error) {
      throw error;
    }
  }


  Future<void> registerChildren(String name, String email, String password,
      String role) async {
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/parents/me/children')
        : Uri.http(apiAuthority, '/api/parents/me/children');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'inscription');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<String?> login(String email, String password) async {
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/login')
        : Uri.http(apiAuthority, '/api/login');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

     // print(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Login response: $responseData');

        _token = responseData['token'];
        await saveToken(_token!);
        _expiryDate = DateTime.now().add(Duration(hours: 24));

        if (responseData['user'] != null && responseData['user'] is Map<String, dynamic>) {
          _user = User.fromJson(responseData['user']);
          print('User from login response: ${_user?.toJson()}');
        } else {
          await fetchUserDetails();
        }

        print('Final user after login: ${_user?.toJson()}');
        notifyListeners();
        await _saveAuthData();
        return _user!.role;
      }
      notifyListeners();
      await _saveAuthData();
      return  _user!.role;
      print('Connexion réussie et détails utilisateur récupérés');
    } catch (error) {
      print('Erreur lors de la connexion: $error');
      // Réinitialiser les données d'authentification en cas d'erreur
      _token = null;
      _expiryDate = null;
      throw error;
    }
  }


  Future<Map<String, dynamic>?>  fetchUserDetails() async {
    if (_token == null) {
      throw Exception('Token non disponible. Utilisateur non authentifié.');
    }

    final url = isSecure
        ? Uri.https(apiAuthority, '/api/users/me')
        : Uri.http(apiAuthority, '/api/users/me');

    try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      print('User data from API: $userData');
      _user = User.fromJson(userData);
      print('Parsed user: ${_user?.toJson()}');
      notifyListeners();
    } else {
      print('Failed to fetch user details. Status code: ${response.statusCode}');
      // Gérer l'erreur appropriée
    }


    final userData = json.decode(response.body);

    _user = User.fromJson(userData);
    notifyListeners();
    await _saveAuthData();
    //print('Détails utilisateur récupérés avec succès: ${_user?.toJson()}');
    } catch (error) {
      print('Erreur lors de la récupération des détails utilisateur: $error');
      _user = null;
      notifyListeners();
      throw Exception('Échec du chargement des données utilisateur');

    }
  }


  Future<void> changePassword(String newPassword) async {
    if (_user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final url = Uri.parse('https://votre-api.com/api/change-password');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'new_password': newPassword,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du changement de mot de passe');
      }

      // Mise à jour de l'utilisateur local avec le nouveau mot de passe
      _user = _user!.copyWithPassword(newPassword);
      // Effacer le mot de passe après utilisation
      //_user!.clearPassword();

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }


  Future<void> logout() async {
    _token = null;
    _userRole = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    await _storage.deleteAll();
  }

  void _setAutoLogoutTimer() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate
        ?.difference(DateTime.now())
        .inSeconds ?? 0;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _user?.id,
      'expiryDate': _expiryDate?.toIso8601String(),
      'user': _user?.toJson(),
      'parent': _parent?.toJson(),
    });
    await prefs.setString('userData', userData);
    print('Saved auth data: $userData');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    print('Extracted user data: $extractedUserData');

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _expiryDate = expiryDate;
    _user = User.fromJson(extractedUserData['user']);
    print('User after auto login: ${_user?.toJson()}');
    notifyListeners();
    return true;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

}