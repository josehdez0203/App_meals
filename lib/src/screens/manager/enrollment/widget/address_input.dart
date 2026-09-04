import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/enrollment/enrollment_controller.dart';

class AddressInput extends StatelessWidget {
  const AddressInput({
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
        maxLines: 4,
        minLines: 1,
        keyboardType: TextInputType.streetAddress,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          icon: const Icon(Icons.maps_home_work_outlined, color: kPrimaryColor),
          hintText: S.of(context).hAddress,
          border: InputBorder.none,
        ),
        initialValue: enrollmentController.enrollment.address,
        onSaved: (address) =>
            enrollmentController.enrollment.address = address!.trim(),
        validator: (value) {
          if (value!.trim().length < 10) {
            return S.of(context).eValidatoCharacters(10);
          }
          return null;
        },
      ),
    );
  }
}
