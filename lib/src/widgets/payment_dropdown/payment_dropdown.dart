import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/widgets/payment_dropdown/payment_dropdown_controller.dart';
import 'package:provider/provider.dart';

class PaymentDropdown extends StatelessWidget {
  const PaymentDropdown({super.key}) ;

  @override
  Widget build(BuildContext context) {
    final paymentDropdownController =
        Provider.of<PaymentDropdownController>(context);
    return _buttonCartSumary(context, paymentDropdownController);
  }

  GestureDetector _buttonCartSumary(BuildContext context,
      PaymentDropdownController paymentDropdownController) {
    return GestureDetector(
      onTap: () {
        onTextFieldTap(context, paymentDropdownController);
      },
      child: Container(
        margin: const EdgeInsets.only(
          left: kDefaultPadding * 0.5,
          right: kDefaultPadding * 0.5,
          bottom: kDefaultPadding * 0.5,
        ),
        padding: const EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (paymentDropdownController.payment.type == TypesPayment.cash)
                  const Icon(Icons.payments_outlined, color: kPrimaryColor),

                if (paymentDropdownController.payment.type ==
                    TypesPayment.money)
                  const Icon(Icons.credit_score_outlined, color: kPrimaryColor),

                if (paymentDropdownController.payment.type == TypesPayment.none)
                  const Icon(Icons.touch_app_outlined, color: kPrimaryColor),

                const SizedBox(width: kDefaultPadding),
                Text(paymentDropdownController.dropdown.name),
                Expanded(child: Container()),
                // const Icon(Icons.credit_score_outlined, color: kPrimaryColor),
              ],
            ),
            Visibility(
                visible: !paymentDropdownController.isPaymentSelected,
                child: const Divider(color: kErrorColor, thickness: 1.5)),
          ],
        ),
      ),
    );
  }

  onTextFieldTap(BuildContext context,
      PaymentDropdownController paymentDropdownController) {
    DropDownState(
      DropDown(
        bottomSheetTitle: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.payments_outlined, color: kPrimaryColor),
              const SizedBox(width: kDefaultPadding),
              Text(S.of(context).lPaymentMethods,
                  style: const TextStyle(fontSize: 17))
            ],
          ),
        ),
        data: paymentDropdownController.paymentItems,
        selectedItems: (List<dynamic> selectedList) async {
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              await paymentDropdownController.setDropdown(item);
            }
          }
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }
}
