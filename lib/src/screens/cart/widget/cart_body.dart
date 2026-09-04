import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/screens/cart/widget/cart_product.dart';

class CartBody extends StatelessWidget {
  final List<ProductModel> products;

  const CartBody({
    super.key,
    required this.products,
  }) ;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.all(kDefaultPadding * 0.3),
        child: CartProduct(product: products[index]),
      ),
    );
  }
}
