import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/cart/cart_controller.dart';
import 'package:app_meals/src/screens/cart/widget/cart_body.dart';
import 'package:app_meals/src/screens/cart_summary/cart_summary_screen.dart';
import 'package:app_meals/src/screens/login/login_screen.dart';
import 'package:app_meals/src/widgets/image_is_empty.dart';
import 'package:app_meals/src/widgets/secondary_button.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartController>.value(
      value: CartController(),
      child: Scaffold(
        appBar: AppBar(title: Text(S.of(context).tMyOrder)),
        body: Consumer<CartController>(
          builder: (context, cartController, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              cartController.products.isEmpty
                  ? const ImageIsEmpty('assets/screen/cart.png', message: '')
                  : Expanded(
                      child: CartBody(products: cartController.products)),
              cartController.products.isEmpty
                  ? Container()
                  : SecondaryButton(
                      color: Theme.of(context).colorScheme.secondary,
                      text: S.of(context).bContinue,
                      onPressed: () {
                        if (cartController.products.length <= 0) return;
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (pref.isAuth) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CartSummaryScreen()));
                        } else {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (Route<dynamic> route) {
                            return false;
                          });
                        }
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }
}
