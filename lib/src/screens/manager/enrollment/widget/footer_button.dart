import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/enrollment/widget/enrollment_form.dart';
import 'package:app_meals/src/widgets/primary_button.dart';

class FooterButton extends StatelessWidget {
  const FooterButton({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: PrimaryButton(
          text: S.of(context).bEstablishLocation,
          onPressed: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EnrollmentForm()));
          },
        ),
      ),
    );
  }
}
