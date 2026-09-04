import 'package:flutter/material.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_screen.dart';
import 'package:app_meals/src/screens/login/access_controller.dart';
import 'package:app_meals/src/screens/login/widget/google_button_controller.dart';
import 'package:app_meals/src/screens/main/tab_main_screen.dart';
import 'package:app_meals/src/screens/manager/requests/requests_screen.dart';
import 'package:provider/provider.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton(
    this.accessController, {
    super.key,
  }) ;

  final AccessController accessController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GoogleButtonController>.value(
      value: GoogleButtonController(),
      child: Consumer<GoogleButtonController>(
        builder: (context, coogleButtonController, child) => GestureDetector(
          child: Image.asset('assets/google.png', height: 55),
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());

            final navigator = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final s = S.of(context);

            accessController.inAsyncCall = true;
            final userLogin = await coogleButtonController.sigInGoogle();
            accessController.inAsyncCall = false;
            if (userLogin != null) {
              MaterialPageRoute route;
              if (userLogin.roles.contains(TypesRol.deliveryman)) {
                route = MaterialPageRoute(
                    builder: (context) => const PetitionsScreen());
              } else if (userLogin.roles.contains(TypesRol.manager)) {
                route = MaterialPageRoute(
                    builder: (context) => const RequestsScreen());
              } else {
                route = MaterialPageRoute(
                    builder: (context) => const TabMainScreen());
              }
              navigator.pushAndRemoveUntil(route, (Route<dynamic> route) {
                return false;
              });
            } else {
              scaffoldMessenger
                  .showSnackBar(SnackBar(content: Text(s.errUnknown)));
            }
          },
        ),
      ),
    );
  }
}
