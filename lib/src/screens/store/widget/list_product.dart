import 'package:flutter/material.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';
import 'package:app_meals/src/screens/store/widget/info_product.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:app_meals/src/widgets/product_added_cart.dart';
import 'package:provider/provider.dart';

class ListProduct extends StatelessWidget {
  final List<ProductModel> products;

  const ListProduct(this.products, {super.key}) ;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) => _Product(products[index]),
    );
  }
}

class _Product extends StatelessWidget {
  final ProductModel product;
  final double height = 150;

  const _Product(this.product);

  @override
  Widget build(BuildContext context) {
    final iconCartController = Provider.of<IconCartController>(context);
    final tab1Controller = Provider.of<Tab1Controller>(context, listen: false);
    final card = SizedBox(
      height: height,
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            AvatarImage(image: product.image),
            InfoProduct(height: height, product: product),
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        card,
        product.isInCart ? const ProductAddedCart() : Container(),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withValues(alpha: (0.6 * 255)),
                onTap: () async {
                  if (!product.isInCart) {
                    await DBProvider.db
                        .createProduct(product, TypesCompany.store);
                  } else {
                    await DBProvider.db.deleteProduct(product);
                  }
                  product.isInCart = !product.isInCart;
                  iconCartController.items =
                      await DBProvider.db.countProducts(TypesCompany.store);
                  tab1Controller.setProducts(product);
                }),
          ),
        ),
      ],
    );
  }
}
