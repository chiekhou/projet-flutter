import 'package:flutter/material.dart';
import 'package:flutter_app/models/message_model.dart';
import 'package:provider/provider.dart';

import '../../services/chat_service.dart';

class UnreadMessagesScreen extends StatefulWidget {
  @override
  _UnreadMessagesScreenState createState() => _UnreadMessagesScreenState();
}

class _UnreadMessagesScreenState extends State<UnreadMessagesScreen> {
  late Future<List<MessageModel>> _unreadMessagesFuture;

  @override
  void initState() {
    super.initState();
    final chatService = Provider.of<ChatService>(context, listen: false);
    _unreadMessagesFuture = chatService.getUnreadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unread Messages')),
      body: FutureBuilder<List<MessageModel>>(
        future: _unreadMessagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No unread messages'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final message = snapshot.data![index];
                return ListTile(
                  title: Text(message.contenu!),
                  subtitle: Text('From: ${message.expediteur?.name ?? 'Unknown'}'),
                  trailing: Text(message.date.toString()),
                  onTap: () {
                    // Naviguer vers la conversation complète ou marquer comme lu
                    Provider.of<ChatService>(context, listen: false).markMessageAsRead(message.id!);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _unreadMessagesFuture = Provider.of<ChatService>(context, listen: false).getUnreadMessages();
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}