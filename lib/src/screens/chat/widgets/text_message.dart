import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/chat_message_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

class TextMessage extends StatelessWidget {
  TextMessage({
    super.key,
    required this.message,
  });

  final ChatMessageModel message;
  final prefs = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isSender(prefs.user.id)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          width: message.message.length > 44 ? 220 : null,
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 0.75,
            vertical: kDefaultPadding / 2,
          ),
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(
                alpha: message.isSender(prefs.user.id) ? 255 : (0.1 * 255)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.message,
            style: TextStyle(
              color: message.isSender(prefs.user.id)
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ),
        MessageTimeStatus(message: message)
      ],
    );
  }
}

class MessageTimeStatus extends StatelessWidget {
  final ChatMessageModel message;

  const MessageTimeStatus({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    String time = message.createdAt.toLocal().toString().substring(10, 16);
    return Container(
      margin: const EdgeInsets.only(right: kDefaultPadding / 2),
      child: Text(
        time,
        style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: color(message.status, context)),
      ),
    );
  }

  Color color(int status, BuildContext context) {
    switch (status) {
      case 404:
        return kErrorColor;
      case 201:
        return Theme.of(context)
            .textTheme
            .bodyLarge!
            .color!
            .withValues(alpha: (0.1 * 255));
      case 300:
        return kPrimaryColor;
      default:
        return kPrimaryColor;
    }
  }
}
