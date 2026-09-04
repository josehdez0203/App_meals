import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/product/product_controller.dart';

class DescriptionInput extends StatelessWidget {
  const DescriptionInput({
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
        maxLines: 4,
        minLines: 1,
        keyboardType: TextInputType.streetAddress,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          icon: const Icon(Icons.description_outlined, color: kPrimaryColor),
          hintText: S.of(context).hProductDescription,
          border: InputBorder.none,
        ),
        initialValue: productController.companyProduct.description,
        onSaved: (description) =>
            productController.companyProduct.description = description!,
        validator: (value) {
          if (value!.trim().length < 10) {
            return S.of(context).eValidatoCharacters(10);
          }
          return null;
        },
      ),
    );
  }
}
