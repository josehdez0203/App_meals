import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/chat_message_model.dart';
import 'package:app_meals/src/models/chat_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/chat/widgets/text_message.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';

class Message extends StatelessWidget {
  Message({
    super.key,
    required this.chatModel,
    required this.message,
  }) ;

  final ChatMessageModel message;
  final ChatModel chatModel;
  final prefs = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    Widget messageContaint(ChatMessageModel message) {
      switch (message.type) {
        case 1:
          return TextMessage(message: message);
        default:
          return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: Row(
        mainAxisAlignment: message.isSender(prefs.user.id)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isSender(prefs.user.id)) ...[
            SizedBox(
              width: 30,
              child:
                  ClipOval(child: AvatarImage(image: chatModel.toUser.image)),
            ),
            const SizedBox(width: kDefaultPadding / 2),
          ],
          messageContaint(message),
        ],
      ),
    );
  }
}
