import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/screens/cart_summary/cart_summary_controller.dart';
import 'package:app_meals/src/screens/cart_summary/widget/company_products.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';
import 'package:app_meals/src/screens/main/tab2_controller.dart';
import 'package:app_meals/src/screens/main/tab_main_controller.dart';
import 'package:app_meals/src/widgets/address_dropdown/address_dropdown.dart';
import 'package:app_meals/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:app_meals/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:app_meals/src/widgets/money_input.dart';
import 'package:app_meals/src/widgets/payment_dropdown/payment_dropdown.dart';
import 'package:app_meals/src/widgets/payment_dropdown/payment_dropdown_controller.dart';
import 'package:app_meals/src/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class BodyCart extends StatelessWidget {
  const BodyCart({
    super.key,
  }) ;

  @override
  Widget build(BuildContext context) {
    final paymentController = Provider.of<PaymentDropdownController>(context);
    final cartSummaryController = Provider.of<CartSummaryController>(context);
    final double width = MediaQuery.of(context).size.width;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: AddressDropdown(isScreenMain: false)),
        const SliverToBoxAdapter(child: PaymentDropdown()),
        if (cartSummaryController.money > 0)
          SliverToBoxAdapter(child: MoneyInput(cartSummaryController.money)),
        SliverToBoxAdapter(
            child: CompanyProducts(
                cartSummaryController: cartSummaryController, width: width)),
        SliverToBoxAdapter(
            child: _paymentMethodButton(
                context, paymentController, cartSummaryController)),
      ],
    );
  }

  Widget _paymentMethodButton(
      BuildContext context,
      PaymentDropdownController paymentController,
      CartSummaryController cartSummaryController) {
    double total = double.parse(
        cartSummaryController.total.toStringAsFixed(kCoinDecimals));

    switch (paymentController.payment.type) {
      case TypesPayment.money:
        total = total - cartSummaryController.money;
        if (total < 0) total = 0;
        total = double.parse(total.toStringAsFixed(kCoinDecimals));

        return PrimaryButton(
          color: Theme.of(context).colorScheme.primary,
          text: "${S.of(context).bPay} $total $kCoin",
          icon: Icons.credit_score_outlined,
          onPressed: () {
            _onPressedBuy(
                context, paymentController, cartSummaryController, total);
          },
        );

      case TypesPayment.cash:
        return PrimaryButton(
          color: Theme.of(context).colorScheme.primary,
          text:
              "${S.of(context).bPay} ${total.toStringAsFixed(kCoinDecimals)} $kCoin",
          icon: Icons.payments_outlined,
          onPressed: () {
            _onPressedBuy(
                context, paymentController, cartSummaryController, total);
          },
        );
      default:
        return PrimaryButton(
          color: Theme.of(context).colorScheme.primary,
          text:
              "${S.of(context).bPay} ${total.toStringAsFixed(kCoinDecimals)} $kCoin",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: kErrorColor,
              content: Text(S.of(context).lselectPayment),
            ));
          },
        );
    }
  }

  _onPressedBuy(
      BuildContext context,
      PaymentDropdownController paymentController,
      CartSummaryController cartSummaryController,
      double total) async {
    if (cartSummaryController.products.isEmpty) return;

    if (paymentController.payment.type == TypesPayment.cash && total <= 0) {
      return;
    }

    if (paymentController.payment.type == TypesPayment.money) {
      if (cartSummaryController.money <= 0 && total <= 0) {
        return;
      }

      if (total > 0 && total < kMinPurchaseAmountCard) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: kErrorColor,
          duration: const Duration(seconds: 12),
          content: Text(S
              .of(context)
              .errMinPurchaseAmountCard(kMinPurchaseAmountCard, kCoin)),
        ));
        return;
      }
    }

    paymentController.isPaymentSelected = false;

    final iconCartController =
        Provider.of<IconCartController>(context, listen: false);

    final tabManController =
        Provider.of<TabManController>(context, listen: false);
    final tab1Controller = Provider.of<Tab1Controller>(context, listen: false);
    final tab2Controller = Provider.of<Tab2Controller>(context, listen: false);
    final addressDropdownController =
        Provider.of<AddressDropdownController>(context, listen: false);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final s = S.of(context);

    AddressModel? address = await DBProvider.db.loadAddress();

    if (address == null || address.id <= 0) {
      scaffoldMessenger.showSnackBar(SnackBar(
          backgroundColor: kErrorColor, content: Text(s.bSelectAddress)));
      return;
    }

    if (address.id !=
        int.parse(addressDropdownController.dropdown.value.toString())) {
      scaffoldMessenger.showSnackBar(SnackBar(
          backgroundColor: kErrorColor, content: Text(s.bSelectAddress)));
      if (kDebugMode) {
        print('Serious error. Address does not correspond');
      }
      return;
    }

    if (paymentController.payment.type == TypesPayment.money &&
        total >= kMinPurchaseAmountCard) {
      bool isPayGenerate = await cartSummaryController.makePayment(
          money: total, currency: kCoin);
      if (!isPayGenerate) {
        scaffoldMessenger.showSnackBar(SnackBar(
            backgroundColor: kErrorColor, content: Text(s.errUnknown)));
        return;
      }
    }

    bool response =
        await cartSummaryController.buy(paymentController.payment.type);

    if (!response) {
      scaffoldMessenger.showSnackBar(
          SnackBar(backgroundColor: kErrorColor, content: Text(s.errUnknown)));
      return;
    }

    navigator.popUntil((route) => route.isFirst);

    tabManController.currentScreen = 1;

    tab1Controller.load();
    tab2Controller.loadOrders();
    iconCartController.count();

    paymentController.isPaymentSelected = false;
  }
}
