import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/profile/profile_controller.dart';
import 'package:app_meals/src/screens/profile/widget/password_input.dart';

class PasswordDialog extends StatelessWidget {
  PasswordDialog(this.profileController, {super.key, required this.onPressedOk})
      ;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final Function onPressedOk;
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(kDefaultPadding * 1.6),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding * 0.2, vertical: kDefaultPadding),
      content: Form(key: formKey, child: PasswordInput(profileController)),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
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
            FocusScope.of(context).requestFocus(FocusNode());
            formKey.currentState!.save();
            if (!formKey.currentState!.validate()) return;
            Navigator.of(context).pop();
            onPressedOk();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save_as_outlined),
              const SizedBox(width: kDefaultPadding * .5),
              Text(S.of(context).bAccept),
              const SizedBox(width: kDefaultPadding * .5),
            ],
          ),
        )
      ],
    );
  }
}
