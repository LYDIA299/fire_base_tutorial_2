import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:fire_base_flutter_chat/models/chat.dart';
import 'package:fire_base_flutter_chat/models/message.dart';
import 'package:fire_base_flutter_chat/models/user_profile.dart';
import 'package:fire_base_flutter_chat/services/auth_service.dart';
import 'package:fire_base_flutter_chat/services/database_service.dart';
import 'package:fire_base_flutter_chat/services/media_service.dart';
import 'package:fire_base_flutter_chat/services/storage_service.dart';
import 'package:fire_base_flutter_chat/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt<AuthService>();
    _mediaService = _getIt<MediaService>();
    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    _databaseService = _getIt<DatabaseService>();
    _storageService = _getIt<StorageService>();
    otherUser = ChatUser(
        id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.chatUser.name!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> chatMessages = [];
        if (chat != null && chat.messages != null) {
          chatMessages = _generateChatMessagsList(chat.messages!);
        }
        return DashChat(
          messageOptions: const MessageOptions(
            showOtherUsersAvatar: true,
            showTime: true,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            trailing: [
              _mediaMessageButton(),
            ],
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: chatMessages,
        );
      },
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser!.id,
          message,
        );
      }
    } else {
      Message message = Message(
        senderID: _authService.user!.uid,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );

      await _databaseService.sendChatMessage(
        currentUser!.id,
        otherUser!.id,
        message,
      );
    }
  }

  List<ChatMessage> _generateChatMessagsList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
          medias: [
            ChatMedia(url: m.content!, fileName: '', type: MediaType.image)
          ],
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      } else {
        return ChatMessage(
          text: m.content!,
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatID =
              generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
          String? imageMessage = await _storageService.uploadImageToChat(
              file: file, chatID: chatID);

          if (imageMessage != null) {
            ChatMessage chatMessage = ChatMessage(
              user: currentUser!,
              createdAt: DateTime.now(),
              medias: [
                ChatMedia(
                    url: imageMessage, fileName: '', type: MediaType.image)
              ],
            );
            _sendMessage(chatMessage);
          }
        }
      },
      icon: Icon(
        Icons.image,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
