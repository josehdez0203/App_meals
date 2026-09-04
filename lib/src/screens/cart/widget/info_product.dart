import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/screens/cart/cart_controller.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';
import 'package:app_meals/src/screens/store/store_controller.dart';
import 'package:app_meals/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:provider/provider.dart';

class InfoProduct extends StatelessWidget {
  const InfoProduct({
    super.key,
    required this.height,
    required this.product,
  }) ;

  final double height;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final iconCartController =
        Provider.of<IconCartController>(context, listen: false);
    final cartController = Provider.of<CartController>(context, listen: false);
    final storeController =
        Provider.of<StoreController>(context, listen: false);
    final tab1Controller = Provider.of<Tab1Controller>(context, listen: false);
    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.only(left: 10.0, top: 3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 5.0),
            Text(product.name),
            const SizedBox(height: 5.0),
            Text(
              product.description,
              style: const TextStyle(color: Colors.blueGrey),
            ),
            Expanded(child: Container()),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.blueGrey),
                  onPressed: () async {
                    await cartController.removeProduct(product);
                    iconCartController.count();
                    storeController.setProducts(product);
                    tab1Controller.setProducts(product);
                  },
                ),
                Expanded(child: Container()),
                Text('${(product.total).toStringAsFixed(kCoinDecimals)} $kCoin',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
