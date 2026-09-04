import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/product_model.dart';

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
    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.only(left: 10.0, top: 3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 15.0),
            Text(product.name),
            const SizedBox(height: 15.0),
            Text(
              product.description,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12.0),
            ),
            Expanded(child: Container()),
            Row(
              children: [
                Expanded(child: Container()),
                Text('${(product.price).toStringAsFixed(kCoinDecimals)} $kCoin',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15.0),
              ],
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
