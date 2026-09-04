import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/profile/profile_controller.dart';
import 'package:app_meals/src/widgets/primary_button.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton(
    this.profileController, {
    super.key,
    required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;
  final ProfileController profileController;
  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: S.of(context).bSaveChanges,
      onPressed: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        _formKey.currentState!.save();
        if (!_formKey.currentState!.validate()) return;

        final s = S.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        if (profileController.phone.length <= 6) {
          scaffoldMessenger.showSnackBar(SnackBar(
            backgroundColor: kErrorColor,
            content: Text(S.of(context).errPhoneNumberAgain),
          ));
          return;
        }

        profileController.inAsyncCall = true;

        final codeError = await profileController.update();
        profileController.inAsyncCall = false;
        String? error;

        switch (codeError) {
          case CodeError.none:
            scaffoldMessenger.showSnackBar(SnackBar(
              backgroundColor: kPrimaryColor,
              duration: const Duration(milliseconds: 4500),
              content: Text(s.mRChangesMadeCorrectly),
            ));
            break;
          case CodeError.unknown:
            error = s.errUnknown;
            break;
          case CodeError.emailUnique:
            error = s.errEmailUnique(profileController.email);
            break;
          case CodeError.phoneUnique:
            error = s.errPhoneUnique(profileController.phone);
            break;
          default:
        }

        if (error != null) {
          scaffoldMessenger.showSnackBar(SnackBar(
            backgroundColor: kErrorColor,
            duration: const Duration(milliseconds: 4500),
            content: Text(error),
          ));
        }
      },
    );
  }
}
