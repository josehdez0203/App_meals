import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/deliveryman/petition/petition_controller.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:app_meals/src/widgets/circular_button.dart';
import 'package:provider/provider.dart';

class ButtonDeliverFloatHead extends StatelessWidget {
  const ButtonDeliverFloatHead({
    super.key,
    required this.petitionController,
  }) ;

  final PetitionController petitionController;

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: const Icon(Icons.real_estate_agent_outlined,
          color: kPrimaryColor, size: 40),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) =>
              DeliverDialog(petitionController, onPressedOk: () async {
            final petitionsController =
                Provider.of<PetitionsController>(context, listen: false);
            final navigator = Navigator.of(context);
            await petitionController.deliver();
            petitionsController.loadPetitions();
            navigator.popUntil((route) => route.isFirst);
          }),
        );
      },
    );
  }
}

class DeliverDialog extends StatelessWidget {
  const DeliverDialog(this.petitionController,
      {super.key, required this.onPressedOk, this.onPressedCancell})
      ;

  final Function onPressedOk;
  final Function? onPressedCancell;
  final PetitionController petitionController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(kDefaultPadding * 1.6),
      title: Text(S.of(context).mDFinish, textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
            child: RatingBar.builder(
          initialRating: 5,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (raiting) {
            petitionController.petition.scoreDeliveryman = raiting;
          },
        ))
      ]),
      actions: [
        OutlinedButton(
          onPressed: () {
            if (onPressedCancell == null) {
              Navigator.of(context).pop();
            } else {
              onPressedCancell!();
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.reply_outlined),
              const SizedBox(width: kDefaultPadding * .5),
              Text(S.of(context).bCancel),
              const SizedBox(width: kDefaultPadding * .5),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPressedOk();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.real_estate_agent_outlined),
              const SizedBox(width: kDefaultPadding * .5),
              Text(S.of(context).bDone),
              const SizedBox(width: kDefaultPadding * .5),
            ],
          ),
        )
      ],
    );
  }
}
