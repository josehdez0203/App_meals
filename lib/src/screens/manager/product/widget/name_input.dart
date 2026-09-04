import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/product/product_controller.dart';

class NameInput extends StatelessWidget {
  const NameInput({
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
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          icon: const Icon(Icons.shopping_bag_outlined, color: kPrimaryColor),
          hintText: S.of(context).hProductName,
          border: InputBorder.none,
        ),
        initialValue: productController.companyProduct.name,
        onSaved: (name) => productController.companyProduct.name = name!,
        validator: (value) {
          if (value!.trim().length < 4) {
            return S.of(context).eValidatoCharacters(4);
          }
          return null;
        },
      ),
    );
  }
}
