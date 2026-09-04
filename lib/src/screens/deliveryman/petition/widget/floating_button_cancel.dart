import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/status_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/deliveryman/petition/petition_controller.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:app_meals/src/widgets/circular_button.dart';
import 'package:app_meals/src/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class FloatingButtonCancel extends StatelessWidget {
  const FloatingButtonCancel({
    super.key,
    required this.petitionController,
  }) ;

  final PetitionController petitionController;

  @override
  Widget build(BuildContext context) {
    return petitionController.petition.status == StatusOrder.assigned
        ? Positioned(
            top: 280,
            right: kDefaultPadding,
            child: CircularButton(
              icon: const Icon(Icons.cancel_outlined,
                  color: kErrorColor, size: 40),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmationDialog(
                    S.of(context).mDCancelOrder(S.of(context).bCancel),
                    labelOk: S.of(context).bCancel,
                    labelCancel: S.of(context).bReturn,
                    backgroundColor: kErrorColor,
                    iconOk: const Icon(Icons.cancel_outlined),
                    onPressedOk: () async {
                      final petitionsController =
                          Provider.of<PetitionsController>(context,
                              listen: false);
                      final navigator = Navigator.of(context);
                      await petitionController.cancel();
                      petitionsController.loadPetitions();
                      navigator.popUntil((route) => route.isFirst);
                    },
                  ),
                );
              },
            ),
          )
        : Container();
  }
}
