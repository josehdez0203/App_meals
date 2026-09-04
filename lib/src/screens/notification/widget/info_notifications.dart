import 'package:flutter/material.dart';
import 'package:app_meals/src/models/notification_model.dart';

class InfoNotifications extends StatelessWidget {
  const InfoNotifications({
    super.key,
    required this.height,
    required this.notification,
  }) ;

  final double height;
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.only(left: 10.0, top: 3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 15.0),
            Text(notification.detail),
            const SizedBox(height: 15.0),
            Text(
              notification.hint,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12.0),
            ),
            Expanded(child: Container()),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
