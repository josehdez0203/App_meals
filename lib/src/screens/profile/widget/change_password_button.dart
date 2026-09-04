import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/profile/profile_controller.dart';
import 'package:app_meals/src/screens/profile/widget/password_dialog.dart';
import 'package:app_meals/src/widgets/secondary_button.dart';

class ChangePasswordButton extends StatelessWidget {
  const ChangePasswordButton(
    this.profileController, {
    super.key,
  }) ;

  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
        text: S.of(context).bChangePassword,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                PasswordDialog(profileController, onPressedOk: () async {
              final s = S.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              bool isUpdated = await profileController.updatePasswor();

              if (isUpdated) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  backgroundColor: kPrimaryColor,
                  duration: const Duration(milliseconds: 4500),
                  content: Text(s.mRChangesMadeCorrectly),
                ));
              } else {
                scaffoldMessenger.showSnackBar(SnackBar(
                  backgroundColor: kErrorColor,
                  duration: const Duration(milliseconds: 4500),
                  content: Text(s.errUnknown),
                ));
              }
            }),
          );
        });
  }
}
