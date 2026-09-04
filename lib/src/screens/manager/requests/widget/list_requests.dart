import 'package:flutter/material.dart';
import 'package:app_meals/src/models/request_model.dart';
import 'package:app_meals/src/screens/manager/request/request_screen.dart';
import 'package:app_meals/src/screens/manager/requests/widget/info_requests.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/card_notifications_icon.dart';

class ListRequests extends StatelessWidget {
  final List<RequestModel> requests;

  const ListRequests(this.requests, {super.key}) ;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) => _Request(requests[index]),
    );
  }
}

class _Request extends StatelessWidget {
  final RequestModel request;
  final double height = 150;

  const _Request(this.request);

  @override
  Widget build(BuildContext context) {
    final card = SizedBox(
      height: height,
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            AvatarImage(image: request.store.company.image),
            InfoRequests(height: height, request: request),
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withValues(alpha: (0.6 * 255)),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestScreen(request),
                    ),
                  );
                }),
          ),
        ),
        CardNotificationsIcon(
          notifications: request.notificationsDeliveryman,
          status: request.status,
        )
      ],
    );
  }
}
