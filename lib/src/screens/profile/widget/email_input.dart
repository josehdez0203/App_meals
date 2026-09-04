import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/validator.dart';
import 'package:app_meals/src/screens/profile/profile_controller.dart';

class EmailInput extends StatelessWidget {
  const EmailInput(
    this.profileController, {
    super.key,
  }) ;
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.75),
      margin: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.5),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          icon:
              const Icon(Icons.mark_email_read_outlined, color: kPrimaryColor),
          hintText: S.of(context).hEmail,
          border: InputBorder.none,
        ),
        initialValue: profileController.email,
        onSaved: (email) => profileController.email = email!,
        validator: (value) => validateEmail(context, value!),
      ),
    );
  }
}
