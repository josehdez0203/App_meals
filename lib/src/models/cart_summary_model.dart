import 'dart:convert';

import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/models/fee_model.dart';
import 'package:app_meals/src/models/product_model.dart';

class CartSummaryModel {
  CartSummaryModel({
    required this.products,
    required this.fee,
  });

  double get total {
    double total = 0.0;
    for (var product in products) {
      total += product.total;
    }
    return total + fee.deliveryfee;
  }

  List<ProductModel> products;
  FeeModel fee;

  Object toHttpBodyBuy(AddressModel address, int payment) => jsonEncode({
        "store": {"id": fee.storeId},
        "note": address.alias.trim(),
        "address": address.address.trim(),
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "start": Location(x: fee.fromlt, y: fee.fromlg).toJson(),
        "location": address.location.toJson(), //Destination
        "total": double.parse(total.toStringAsFixed(kCoinDecimals)),
        "deliveryFee":
            double.parse(fee.deliveryfee.toStringAsFixed(kCoinDecimals)),
        //Date in the client's time zone.
        "orderedAt": DateTime.now().toString().split(' ')[0],
        "payment": payment
      });
}
