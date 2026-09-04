import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/petition_model.dart';
import 'package:app_meals/src/screens/deliveryman/petition/petition_screen.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:provider/provider.dart';
import 'package:slidable_button/slidable_button.dart';

class SliderApply extends StatelessWidget {
  const SliderApply(
    this.petition, {
    super.key,
  }) ;
  final PetitionModel petition;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 10,
      child: HorizontalSlidableButton(
        borderRadius: BorderRadius.circular(5),
        width: 230,
        buttonWidth: 80.0,
        buttonColor: Colors.white,
        color: kSecondaryColor,
        dismissible: false,
        label: const Center(
            child: Icon(Icons.delivery_dining_outlined, color: kPrimaryColor)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '>>>',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '>> ${S.of(context).sSlideApply} ',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        onChanged: (position) async {
          if (position != SlidableButtonPosition.end) return;

          final petitionsController =
              Provider.of<PetitionsController>(context, listen: false);

          final navigator = Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final sContext = S.of(context);

          final List response = await petitionsController.apply(petition);

          final codeError = response[0];
          String? error;

          switch (codeError) {
            case CodeError.none:
              petitionsController.loadPetitions();
              navigator.push(MaterialPageRoute(
                builder: (context) => PetitionScreen(response[1]),
              ));
              break;
            case CodeError.unknown:
              error = sContext.errUnknown;
              break;
            case CodeError.notBalance:
            case CodeError.insufficientBalance:
              error = sContext.mRinsufficientBalance;
              break;
            case CodeError.orderFulfilled:
              error = sContext.mRorderFulfilled;
              petitionsController.removeOrder(petition);
              break;
            default:
          }

          if (error != null) {
            scaffoldMessenger.showSnackBar(SnackBar(
              duration: const Duration(seconds: 5),
              backgroundColor: kErrorColor,
              content: Text(error),
            ));
          }
        },
      ),
    );
  }
}
