import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';

class SheetChatIcon extends StatelessWidget {
  const SheetChatIcon({
    super.key,
    required this.notifications,
    required this.goToChatScreen,
  });

  final int notifications;
  final Function goToChatScreen;

  @override
  Widget build(BuildContext context) {
    if (notifications <= 0) {
      return IconButton(
          icon: const Icon(
            Icons.chat_outlined,
            color: kPrimaryColor,
            size: 33,
          ),
          onPressed: () => goToChatScreen(context));
    }
    return GestureDetector(
      onTap: () => goToChatScreen(context),
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: -5, end: 15),
        badgeContent: Text(
          notifications.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        child: IconButton(
            icon: const Icon(
              Icons.chat_outlined,
              color: kPrimaryColor,
              size: 33,
            ),
            onPressed: () => goToChatScreen(context)),
      ),
    );
  }
}
