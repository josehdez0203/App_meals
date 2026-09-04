import 'package:flutter/material.dart';
import 'package:app_meals/constants/status_constant.dart';
import 'package:app_meals/src/screens/deliveryman/petition/petition_controller.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/button_collect_float_head.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/button_deliver_float_head.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';

class FloatingHead extends StatelessWidget {
  const FloatingHead({
    super.key,
    required this.petitionController,
  }) ;

  final PetitionController petitionController;

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
              onTap: petitionController.centerMap,
              child: ClipOval(
                  child: AvatarImage(
                      image: petitionController.petition.user.image)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(petitionController.petition.user.fullName),
                  const SizedBox(height: 5),
                  Text(petitionController.petition.store.name),
                ],
              ),
            ),
            _buttonFloatHead(petitionController)
          ],
        ),
      ),
    );
  }

  Widget _buttonFloatHead(PetitionController petitionController) {
    switch (petitionController.petition.status) {
      case StatusOrder.assigned:
        return ButtonCollectFloatHead(petitionController: petitionController);
      case StatusOrder.taken:
        return ButtonDeliverFloatHead(petitionController: petitionController);
      default:
        return Container();
    }
  }
}
