import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/chat/chat_controller.dart';

class ChatInput extends StatelessWidget {
  final ChatController chatController;

  const ChatInput(
    this.chatController, {
    super.key,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          bottom: kDefaultPadding * .6, left: kDefaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding * 0.75),
              decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
                  borderRadius: BorderRadius.circular(40)),
              child: TextFormField(
                controller: chatController.textControlle,
                maxLines: 4,
                minLines: 1,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  icon: const Icon(Icons.edit_note_sharp, color: kPrimaryColor),
                  hintText: S.of(context).hChat,
                  border: InputBorder.none,
                ),
                onEditingComplete: () => _sendMessage(context),
              ),
            ),
          ),
          const SizedBox(width: kDefaultPadding * .05),
          IconButton(
              onPressed: () => _sendMessage(context),
              icon: const Icon(Icons.send, color: kPrimaryColor)),
        ],
      ),
    );
  }

  _sendMessage(BuildContext context) {
    chatController.sendText();
  }
}
