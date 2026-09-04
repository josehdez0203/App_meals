import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/models/chat_model.dart';
import 'package:app_meals/src/screens/chat/chat_controller.dart';
import 'package:app_meals/src/screens/chat/widgets/chat_input.dart';
import 'package:app_meals/src/screens/chat/widgets/message.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:app_meals/src/screens/main/tab2_controller.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  final ChatModel chatModel;
  final String myRol;

  const ChatScreen({super.key, required this.chatModel, required this.myRol});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatController>.value(
      value: ChatController(
          orderId: chatModel.orderId, toId: chatModel.toUser.id, myRol: myRol),
      child: Consumer<ChatController>(
        builder: (context, chatController, child) => PopScope(
          onPopInvoked: (didPop) async {
            chatController.markAllRead();
            if (myRol == TypesRol.client) {
              Provider.of<Tab2Controller>(context, listen: false)
                  .cleanNotificationsClient(chatModel.orderId);
            } else if (myRol == TypesRol.deliveryman) {
              Provider.of<PetitionsController>(context, listen: false)
                  .cleanNotificationsDeliveryman(chatModel.orderId);
            }
            return;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chatModel.toUser.fullName,
                      style: const TextStyle(fontSize: 16)),
                  Text(chatModel.label, style: const TextStyle(fontSize: 12))
                ],
              ),
              actions: [
                ClipOval(child: AvatarImage(image: chatModel.imageCompany)),
                const SizedBox(width: kDefaultPadding * 0.75)
              ],
            ),
            body: ContentChat(chatController, chatModel: chatModel),
          ),
        ),
      ),
    );
  }
}

class ContentChat extends StatefulWidget {
  const ContentChat(
    this.chatController, {
    super.key,
    required this.chatModel,
  });

  final ChatModel chatModel;
  final ChatController chatController;

  @override
  State<ContentChat> createState() => _ContentChatState();
}

class _ContentChatState extends State<ContentChat> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        widget.chatController.loadMessages();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: widget.chatController.inAsyncCall,
          child: const LinearProgressIndicator(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: ListView.builder(
              reverse: true,
              controller: widget.chatController.scrollController,
              itemCount: widget.chatController.messages.length,
              itemBuilder: (context, index) => Message(
                  message: widget.chatController.messages[index],
                  chatModel: widget.chatModel),
            ),
          ),
        ),
        ChatInput(widget.chatController),
      ],
    );
  }
}
