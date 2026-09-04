import 'package:flutter/material.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/models/chat_message_model.dart';
import 'package:app_meals/src/provider/push_provider.dart';
import 'package:app_meals/src/services/chat_service.dart';

class ChatController with ChangeNotifier {
  final _pushProvider = PushProvider();

  final ChatService chatService = ChatService();
  late int orderId;
  late int toId;
  late String myRol;

  final TextEditingController _textControlle = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessageModel> _messages = [];

  ChatController(
      {required this.orderId, required this.toId, required this.myRol}) {
    loadMessages();
    chatService.markAllRead(myRol, orderId);
    _pushProvider.notifications.listen(evaluateNotification);
  }

  markAllRead() {
    chatService.markAllRead(myRol, orderId);
  }

  evaluateNotification(Map<String, dynamic> notification) {
    if (orderId.toString() == notification['orderId']) {
      switch (notification['type']) {
        case TypesNotification.changeOrderStatust:
          ////>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          break;
        case TypesNotification.messageChat:
          final ChatMessageModel chatMessage = ChatMessageModel(
            message: notification['message'].toString(),
            createdAt: DateTime.now().toUtc(),
            from: From(id: int.parse(notification['fromId'].toString())),
            orderId: int.parse(notification['orderId'].toString()),
          );
          addMessage(chatMessage);
          break;
        default:
      }
    }
  }

  ScrollController get scrollController => _scrollController;

  TextEditingController get textControlle => _textControlle;

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  List<ChatMessageModel> get messages => _messages;

  set messages(List<ChatMessageModel> messages) {
    _messages.clear();
    _messages.addAll(messages);
    notifyListeners();
  }

  loadMessages() async {
    messages = await chatService.getChats(orderId);
    notifyListeners();
  }

  sendText() {
    if (_textControlle.text.isEmpty) return;
    final ChatMessageModel chatMessage = ChatMessageModel(
      message: _textControlle.text,
      createdAt: DateTime.now().toUtc(),
      toId: toId,
      orderId: orderId,
    );
    _textControlle.text = '';
    chatService.send(myRol, chatMessage);
    addMessage(chatMessage);
  }

  addMessage(ChatMessageModel chatMessage) {
    _messages.insert(0, chatMessage);
    notifyListeners();
  }
}
