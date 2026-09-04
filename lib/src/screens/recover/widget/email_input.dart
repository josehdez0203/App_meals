import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/validator.dart';
import 'package:app_meals/src/screens/recover/recover_controller.dart';

class EmailInput extends StatelessWidget {
  const EmailInput(
    this.recoverController, {
    super.key,
  }) ;
  final RecoverController recoverController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
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
            icon: const Icon(Icons.mail_lock_outlined, color: kPrimaryColor),
            hintText: S.of(context).hEmail,
            border: InputBorder.none,
          ),
          onSaved: (email) => recoverController.email = email!,
          validator: (value) => validateEmail(context, value!),
        ),
      ),
    );
  }
}
