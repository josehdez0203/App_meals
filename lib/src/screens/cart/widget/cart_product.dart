import 'package:flutter/material.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/screens/cart/cart_controller.dart';
import 'package:app_meals/src/screens/cart/widget/info_product.dart';
import 'package:app_meals/src/screens/cart/widget/note_input.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:provider/provider.dart';

class CartProduct extends StatelessWidget {
  const CartProduct({
    super.key,
    required this.product,
  }) ;
  final double height = 150;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            InfoProduct(height: height, product: product),
            SizedBox(
              width: 125,
              child: Column(
                children: [
                  AvatarImage(
                    image: product.image,
                    borderRadius:
                        const BorderRadius.only(topRight: Radius.circular(10)),
                  ),
                  Text(
                    product.companyName,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(shape: const CircleBorder()),
                    child: const Icon(Icons.remove),
                    onPressed: () {
                      if (product.number == 1) return;
                      product.number--;
                      cartController.updateProduct(product);
                    },
                  ),
                  const SizedBox(width: 10.0),
                  Text('${product.number}',
                      style: const TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10.0),
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.add),
                    onPressed: () {
                      product.number++;
                      cartController.updateProduct(product);
                    },
                  ),
                ],
              ),
              NoteInput(product: product, cartController: cartController),
              const SizedBox(height: 10),
              const Divider(height: 15)
            ],
          ),
        ),
      ],
    );
  }
}
