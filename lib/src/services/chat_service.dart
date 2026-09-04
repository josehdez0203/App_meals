import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/chat_message_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlChat = 'chat/order';
const _urlSend = 'chat';
const _urlMarkAllRead = 'chat';

class ChatService {
  final prefs = PreferencesProvider();

  Future<List<ChatMessageModel>> getChats(int orderId) async {
    List<ChatMessageModel> chatsMessage = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlChat/$orderId'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return chatsMessage;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['messages']) {
        chatsMessage.add(ChatMessageModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('ChatService getChats: $err');
      }
    } finally {
      client.close();
    }
    return chatsMessage;
  }

  Future<bool> send(String rol, ChatMessageModel chatMessage) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse('$kDomain$_urlSend'),
          headers: {
            'Authorization': 'Bearer ${prefs.token}',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: chatMessage.toHttpBody(rol));
      if (resp.statusCode != 200) return false;
    } catch (err) {
      if (kDebugMode) {
        print('ChatService send: $err');
      }
    } finally {
      client.close();
    }
    return true;
  }

  Future<bool> markAllRead(String rol, int orderId) async {
    var client = http.Client();
    try {
      final resp = await client.patch(Uri.parse('$kDomain$_urlMarkAllRead'),
          headers: {
            'Authorization': 'Bearer ${prefs.token}',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "rol": rol,
            "order": {"id": orderId}
          }));
      if (resp.statusCode == 200) return true;
    } catch (err) {
      if (kDebugMode) {
        print('ChatService send: $err');
      }
    } finally {
      client.close();
    }
    return false;
  }
}
