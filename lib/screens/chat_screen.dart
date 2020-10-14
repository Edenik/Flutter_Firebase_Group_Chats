import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat/models/chat_model.dart';
import 'package:firebase_chat/models/message_model.dart';
import 'package:firebase_chat/models/user_data.dart';
import 'package:firebase_chat/services/database_service.dart';
import 'package:firebase_chat/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen(this.chat);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isComposingMeaage = false;
  DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _databaseService.setChatRead(context, widget.chat, true);
  }

  _buildMessagesStream() {}

  _buildMessageTF() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(
                Icons.photo,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                PickedFile pickedFile = await ImagePicker().getImage(
                  source: ImageSource.camera,
                );
                File imageFile = File(pickedFile.path);

                if (imageFile != null) {
                  String imageUrl =
                      await Provider.of<StorageService>(context, listen: false)
                          .uploadMessageImage(imageFile);
                  _sendMessage(null, imageUrl);
                }
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (messageText) {
                setState(() => _isComposingMeaage = messageText.isNotEmpty);
              },
              decoration: InputDecoration.collapsed(hintText: 'Send a Message'),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: _isComposingMeaage
                  ? () => _sendMessage(_messageController.text.trim(), null)
                  : null,
            ),
          )
        ],
      ),
    );
  }

  _sendMessage(String text, String imageUrl) async {
    if ((text != null && text.isNotEmpty) || imageUrl != null) {
      if (imageUrl == null) {
        _messageController.clear();
        setState(() => _isComposingMeaage = false);
      }
      Message message = Message(
        senderId: Provider.of<UserData>(context, listen: false).currentUserId,
        text: text,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
      );
      _databaseService.sendChatMessage(widget.chat, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _databaseService.setChatRead(context, widget.chat, true);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chat.name),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // _buildMessagesStream(),
              Divider(
                height: 1.0,
              ),
              _buildMessageTF()
            ],
          ),
        ),
      ),
    );
  }
}
