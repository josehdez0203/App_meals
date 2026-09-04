import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/screens/cart/cart_controller.dart';

class NoteInput extends StatelessWidget {
  const NoteInput({
    super.key,
    required this.product,
    required this.cartController,
  }) ;

  final ProductModel product;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding * 0.75,
            ),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextFormField(
              onChanged: (value) {
                product.note = value;
                cartController.updateProduct(product);
              },
              maxLines: 4,
              maxLength: 102,
              minLines: 1,
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                icon: const Icon(Icons.edit_note_sharp, color: kPrimaryColor),
                hintText: S.of(context).hNoteProdcut,
                border: InputBorder.none,
              ),
              initialValue: product.note,
              onEditingComplete: () => _saveNote(context),
            ),
          ),
        ),
        // const SizedBox(width: kDefaultPadding * .05),
        // IconButton(
        //     onPressed: () => _saveNote(context),
        //     icon: const Icon(Icons.save_outlined, color: kPrimaryColor)),
      ],
    );
  }

  _saveNote(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    cartController.updateProduct(product);
  }
}
