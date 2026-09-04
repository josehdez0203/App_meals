import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/launch.dart';
import 'package:app_meals/src/screens/manager/request/request_controller.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/circular_button.dart';

class FloatingHead extends StatelessWidget {
  const FloatingHead({
    super.key,
    required this.requestController,
  }) ;

  final RequestController requestController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: requestController.centerMap,
              child: ClipOval(
                  child:
                      AvatarImage(image: requestController.request.user.image)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(requestController.request.user.fullName),
                  const SizedBox(height: 5),
                  Text(S.of(context).lClient),
                ],
              ),
            ),
            CircularButton(
              icon: const Icon(Icons.call_outlined,
                  color: kPrimaryColor, size: 40),
              onPressed: () {
                call(requestController.request.user.phone);
              },
            )
          ],
        ),
      ),
    );
  }
}
