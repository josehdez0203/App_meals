import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/company/company_screen.dart';
import 'package:app_meals/src/screens/manager/enrollment/enrollment_controller.dart';
import 'package:app_meals/src/widgets/secondary_button.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.enrollmentController,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final EnrollmentController enrollmentController;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      color: Theme.of(context).colorScheme.secondary,
      text: S.of(context).bSaveChanges,
      onPressed: () async {
        FocusScope.of(context).requestFocus(FocusNode());

        final s = S.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        if (!_formKey.currentState!.validate()) return;
        _formKey.currentState!.save();

        if (enrollmentController.enrollment.image.isEmpty) {
          scaffoldMessenger.showSnackBar(SnackBar(
            backgroundColor: kErrorColor,
            content: Text(s.errPleaseUploadImage),
          ));
          return;
        }

        if (enrollmentController.enrollment.contact.length < 10) {
          scaffoldMessenger.showSnackBar(SnackBar(
            backgroundColor: kErrorColor,
            content: Text(s.errPhoneNumber),
          ));
          return;
        }
        final navigator = Navigator.of(context);

        final codeError = await enrollmentController.register();

        String? error;

        switch (codeError) {
          case CodeError.none:
            scaffoldMessenger.showSnackBar(SnackBar(
              backgroundColor: kPrimaryColor,
              duration: const Duration(seconds: 25),
              content: Text(s.mRStoreCongratulations),
              action: SnackBarAction(
                label: s.tStores,
                textColor: Colors.white,
                onPressed: () => navigator.push(
                    MaterialPageRoute(builder: (context) => CompanyScreen())),
              ),
            ));
            navigator.popUntil((route) => route.isFirst);
            break;
          case CodeError.unknown:
            error = s.errUnknown;
            break;
          case CodeError.phoneUnique:
            error = s.errPhoneUnique(enrollmentController.enrollment.contact);
            break;
          case CodeError.nameUnique:
            error = s.errNameUnique(enrollmentController.enrollment.name);
            break;
          case CodeError.deliverymanCannotBeManager:
            error = s.errdeliverymanCannotBeManager;
            break;
          default:
        }

        if (error != null) {
          scaffoldMessenger.showSnackBar(SnackBar(
            backgroundColor: kErrorColor,
            content: Text(error),
          ));
        }
      },
    );
  }
}
