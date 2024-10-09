import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/config.dart';
import 'auth_service.dart';

class ChatService with ChangeNotifier {
  late WebSocketChannel _channel;
  final apiAuthority = AppConfig.getApiAuthority();
  final isSecure = AppConfig.isSecure();
  final AuthService _authService = AuthService();
  List<MessageModel> _messages = [];
  int userId;
  String baseUrl;

  ChatService({ required this.userId,  required this.baseUrl}) {
    _connectToWebSocket();
    getUserMessages();
  }
  void updateUserId(int newUserId) {
    if (userId != newUserId) {
      userId = newUserId;
      // Effectuez ici toute logique nécessaire pour gérer le changement d'utilisateur
      notifyListeners();
    }
  }

  void connect() {
    if (_channel != null) return; // Déjà connecté

    final wsUrl = Uri.parse('$baseUrl/$userId');
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      print('WebSocket connected successfully');
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  void _onMessage(dynamic message) {
    // Traiter le message reçu
    print('Received message: $message');
    notifyListeners();
  }

  bool get isConnected => _channel != null;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  List<MessageModel> get messages => _messages;

  void _connectToWebSocket() {

    final wsUrl = Uri.parse('ws://$baseUrl/api/ws/$userId');
    _channel = WebSocketChannel.connect(wsUrl);
    _channel.stream.listen(_onMessageReceived, onError: _onError, onDone: _onDone);
  }

  void _onMessageReceived(dynamic data) {
    final message = MessageModel.fromJson(json.decode(data));
    _messages.add(message);
    notifyListeners();
  }

  void _onError(error) {
    print('WebSocket Error: $error');
    // Implement reconnection logic here
  }

  void _onDone() {
    print('WebSocket connection closed');
    // Implement reconnection logic here
  }

  Future<void> sendMessage(int destinataireID,String contenu) async {

    print('Début de sendMessage');
    print('destinataireID: $destinataireID');
    print('contenu: $contenu');

    final headers = await _getHeaders();
    print('Headers: $headers');

    final url = isSecure
        ? Uri.https(apiAuthority, '/api/messages')
        : Uri.http(apiAuthority, '/api/messages');
    print('URL: $url');

    final messageData = {
      'expediteur_id': userId,
      'destinataire_id': destinataireID,
      'contenu': contenu,
      'date': DateTime.now().toIso8601String(),

    };

    print('Message to send (JSON): ${json.encode(messageData)}');

    try {
      print('Envoi de la requête POST...');
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(messageData),
      );

      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 201) {
        print('Message envoyé avec succès');
        final sentMessage = MessageModel.fromJson(json.decode(response.body));
        _messages.add(sentMessage);
        notifyListeners();
      } else {
        print('Échec de l\'envoi du message. Code de statut: ${response.statusCode}');
        print('Corps de la réponse d\'erreur: ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      rethrow;
    }
  }

  Future<void> getUserMessages() async {
    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/users/$userId/messages')
        : Uri.http(apiAuthority, '/api/users/$userId/messages');
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        _messages = messagesJson
            .map((json) => MessageModel.fromJson(json))
            .where((message) => message != null) // Filtrer les messages null
            .cast<MessageModel>() // Cast nécessaire après le where
            .toList();
        _messages.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      } else if (response.statusCode == 404) {
        _messages = [];
        notifyListeners();
      } else {
        throw Exception('Failed to get user messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user messages: $e');

    }
  }

  Future<List<MessageModel>> getConversation(int otherUserId) async {

    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority,  '/api/conversations/$userId/$otherUserId')
        : Uri.http(apiAuthority,  '/api/conversations/$userId/$otherUserId');


    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        final List<MessageModel> conversationMessages = messagesJson
            .map((json) => MessageModel.fromJson(json))
            .where((message) => message.isValid())
            .toList();
        _updateLocalMessages(conversationMessages);
        notifyListeners();
        return conversationMessages;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to get conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting conversation: $e');
      return [];
    }
  }

  Future<MessageModel> markMessageAsRead(int messageId) async {

    final headers = await _getHeaders();
    final url = isSecure
        ? Uri.https(apiAuthority, '/api/messages/$messageId/read')
        : Uri.http(apiAuthority,  '/api/messages/$messageId/read');

    try {
      final response = await http.put(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final updatedMessage = MessageModel.fromJson(json.decode(response.body));
        _updateLocalMessage(updatedMessage);
        notifyListeners();
        return updatedMessage;
      } else if (response.statusCode == 404) {
        throw Exception('Message not found');
      } else {
        throw Exception('Failed to mark message as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking message as read: $e');
      rethrow;
    }
  }


  Future<List<MessageModel>> getUnreadMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://$baseUrl/api/users/$userId/unread-messages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        final List<MessageModel> unreadMessages = messagesJson.map((json) => MessageModel.fromJson(json)).toList();
        // Optionnel : Mettre à jour la liste locale des messages si nécessaire
        _updateLocalMessagesWithUnread(unreadMessages);
        notifyListeners();
        return unreadMessages;
      } else if (response.statusCode == 404) {
        // Pas de messages non lus, retourner une liste vide
        return [];
      } else {
        throw Exception('Failed to get unread messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting unread messages: $e');
      rethrow;
    }
  }

  void _updateLocalMessage(MessageModel updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
    }
  }

  void _updateLocalMessages(List<MessageModel> newMessages) {

    _messages = newMessages;
    notifyListeners();
  }

  void _updateLocalMessagesWithUnread(List<MessageModel> unreadMessages) {
    // Cette méthode peut être adaptée selon vos besoins spécifiques
    // Par exemple, vous pourriez vouloir ajouter ces messages à votre liste existante
    // ou mettre à jour le statut de lecture des messages existants
    for (var unreadMessage in unreadMessages) {
      final index = _messages.indexWhere((m) => m.id == unreadMessage.id);
      if (index != -1) {
        _messages[index] = unreadMessage;
      } else {
        _messages.add(unreadMessage);
      }
    }
    _messages.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}