import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/validator.dart';
import 'package:app_meals/src/screens/manager/product/product_controller.dart';

class PriceInput extends StatelessWidget {
  const PriceInput({
    super.key,
    required this.productController,
  }) ;

  final ProductController productController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.75),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        keyboardType: TextInputType.number,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          icon: const Icon(Icons.price_check_outlined, color: kPrimaryColor),
          hintText: S.of(context).lPrice,
          border: InputBorder.none,
        ),
        initialValue: productController.companyProduct.price
            .toStringAsFixed(kCoinDecimals),
        onSaved: (price) {
          price = price!.trim();
          price = price.replaceFirst(',', '.');
          productController.companyProduct.price = double.parse(price);
        },
        validator: (value) => validatePrice(context, value!),
      ),
    );
  }
}
