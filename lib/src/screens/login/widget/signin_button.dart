import 'package:flutter/material.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/user_model.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_screen.dart';
import 'package:app_meals/src/screens/login/access_controller.dart';
import 'package:app_meals/src/screens/main/tab_main_screen.dart';
import 'package:app_meals/src/screens/manager/requests/requests_screen.dart';
import 'package:app_meals/src/screens/recover/recover_screen.dart';
import 'package:app_meals/src/widgets/primary_button.dart';

class SigninButton extends StatelessWidget {
  const SigninButton(
    this.accessController, {
    super.key,
    required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;
  final AccessController accessController;
  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: S.of(context).bSignin,
      onPressed: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        _formKey.currentState!.save();
        if (!_formKey.currentState!.validate()) return;

        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final s = S.of(context);

        UserModel? userLogin = await accessController.signin();
        if (userLogin != null) {
          MaterialPageRoute route;
          if (userLogin.roles.contains(TypesRol.deliveryman)) {
            route = MaterialPageRoute(
                builder: (context) => const PetitionsScreen());
          } else if (userLogin.roles.contains(TypesRol.manager)) {
            route =
                MaterialPageRoute(builder: (context) => const RequestsScreen());
          } else {
            route =
                MaterialPageRoute(builder: (context) => const TabMainScreen());
          }
          navigator.pushAndRemoveUntil(route, (Route<dynamic> route) {
            return false;
          });
        } else {
          scaffoldMessenger.showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 4500),
            content: Text(s.mIncorrectLogin),
            action: SnackBarAction(
              label: s.bRecoverAccount,
              textColor: Colors.red,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RecoverScreen())),
            ),
          ));
        }
      },
    );
  }
}
