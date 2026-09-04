import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/admin/credit/credit_controller.dart';
import 'package:app_meals/src/widgets/confirmation_dialog.dart';
import 'package:app_meals/src/widgets/primary_button.dart';

class TopUpBalanceButton extends StatelessWidget {
  const TopUpBalanceButton(
    this.creditController, {
    super.key,
    required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;
  final CreditController creditController;
  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: S.of(context).tTopUpBalance,
      icon: Icons.mobile_friendly_rounded,
      onPressed: () async {
        FocusScope.of(context).requestFocus(FocusNode());

        if (!_formKey.currentState!.validate()) return;
        _formKey.currentState!.save();

        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final sContext = S.of(context);

        final codeError = await creditController.topUpBalance();

        String? error;

        switch (codeError) {
          case CodeError.none:
            if (context.mounted) showConfirmationDialog(context);
            return;
          case CodeError.unknown:
            error = sContext.errUnknown;
            break;
          case CodeError.deliverymanNotFound:
            error = sContext.errDeliverymanNotFound;
            break;
          case CodeError.managerCannotBeDeliveryman:
            error = sContext.errManagerCannotBeDeliveryman;
            break;
          default:
        }

        if (error != null) {
          scaffoldMessenger.showSnackBar(SnackBar(
              backgroundColor: kErrorColor,
              duration: const Duration(milliseconds: 10000),
              content: Text(error)));
        }
      },
    );
  }

  Future<dynamic> showConfirmationDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        S.of(context).mRTopUpBalance(
            creditController.amount.toStringAsFixed(kCoinDecimals),
            kCoin,
            creditController.phone),
        labelOk: S.of(context).bAccept,
        iconOk: const Icon(Icons.price_check_outlined),
        showButtonCancell: false,
        onPressedOk: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
