import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/enrollment/enrollment_controller.dart';

class NameInput extends StatelessWidget {
  const NameInput({
    super.key,
    required this.enrollmentController,
  }) ;

  final EnrollmentController enrollmentController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.75),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          icon: const Icon(Icons.store_outlined, color: kPrimaryColor),
          hintText: S.of(context).hFullName,
          border: InputBorder.none,
        ),
        initialValue: enrollmentController.enrollment.name,
        onSaved: (name) => enrollmentController.enrollment.name = name!.trim(),
        validator: (value) {
          if (value!.trim().length < 5) {
            return S.of(context).eValidatoCharacters(5);
          }
          return null;
        },
      ),
    );
  }
}
