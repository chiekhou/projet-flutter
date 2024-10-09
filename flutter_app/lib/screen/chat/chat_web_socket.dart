import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../config/config.dart';
import '../../services/auth_service.dart';

class WebSocketChatService with ChangeNotifier {
  late WebSocketChannel _channel;
  List<MessageModel> _messages = [];
  int _userId;

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

  WebSocketChatService(this._userId) {
    _connectToWebSocket();
  }

  List<MessageModel> get messages => _messages;

  void _connectToWebSocket() {
    final wsUrl = Uri.parse('ws://your-backend-url.com/api/ws/$_userId');
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

  void sendMessage(int destinataireID, String contenu) {
    final message = MessageModel(
      id: 0, // The server will assign the real ID
      expediteurId: _userId,
      destinataireId: destinataireID,
      contenu: contenu,
      date: DateTime.now(),
      lu:false,
    );
    _channel.sink.add(json.encode(message.toJson()));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}