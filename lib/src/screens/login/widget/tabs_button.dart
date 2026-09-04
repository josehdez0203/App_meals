import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/login/login_controller.dart';
import 'package:provider/provider.dart';

class TabsButton extends StatelessWidget {
  const TabsButton({
    super.key,
    required this.isPageSignin,
  }) ;
  final bool isPageSignin;

  @override
  Widget build(BuildContext context) {
    final loginController =
        Provider.of<LoginController>(context, listen: false);
    return Row(
      children: [
        SizedBox(
          width: 150.0,
          child: TextButton(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(S.of(context).bSignin,
                    style: TextStyle(
                        color: isPageSignin ? kPrimaryColor : kSecondaryColor,
                        fontSize: 20.0)),
                isPageSignin
                    ? const Divider(color: kPrimaryColor, thickness: 3.0)
                    : const SizedBox(height: 20.0)
              ],
            ),
            onPressed: () {
              loginController.currentScreen = 0;
            },
          ),
        ),
        SizedBox(
          width: 150.0,
          child: TextButton(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(S.of(context).bSignup,
                    style: TextStyle(
                        color: !isPageSignin ? kPrimaryColor : kSecondaryColor,
                        fontSize: 20.0)),
                !isPageSignin
                    ? const Divider(color: kPrimaryColor, thickness: 3.0)
                    : const SizedBox(height: 20.0)
              ],
            ),
            onPressed: () {
              loginController.currentScreen = 1;
            },
          ),
        ),
      ],
    );
  }
}
