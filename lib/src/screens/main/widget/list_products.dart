import 'package:flutter/material.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/screens/store/widget/info_product.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:app_meals/src/widgets/product_added_cart.dart';
import 'package:provider/provider.dart';

class ListProducts extends StatelessWidget {
  final List<ProductModel> products;

  const ListProducts(this.products, {super.key}) ;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return _Product(products[index]);
        },
      ),
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
    final card = SizedBox(
      width: 340,
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
                }),
          ),
        ),
      ],
    );
  }
}
