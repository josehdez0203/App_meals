import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/deliveryman/petition/petition_controller.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:app_meals/src/widgets/circular_button.dart';
import 'package:app_meals/src/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class ButtonCollectFloatHead extends StatelessWidget {
  const ButtonCollectFloatHead({
    super.key,
    required this.petitionController,
  }) ;

  final PetitionController petitionController;

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: const Icon(Icons.delivery_dining_outlined,
          color: kPrimaryColor, size: 40),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ConfirmationDialog(S.of(context).mDConfirmOrder,
              iconOk: const Icon(Icons.delivery_dining_outlined),
              labelOk: S.of(context).bDone, onPressedOk: () async {
            final petitionsController =
                Provider.of<PetitionsController>(context, listen: false);
            final s = S.of(context);
            ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
            await petitionController.collect();
            petitionsController.loadPetitions();
            scaffold.showSnackBar(SnackBar(
              backgroundColor: kPrimaryColor,
              content: Text(s.mRConfirmOrde),
            ));
          }),
        );
      },
    );
  }
}
