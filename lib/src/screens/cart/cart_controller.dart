import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';

class CartController extends ChangeNotifier {
  List<ProductModel> _products = [];

  get products => _products;

  CartController() {
    loadProducts();
  }

  loadProducts() async {
    _products = await DBProvider.db.loadProducts(TypesCompany.store);
    notifyListeners();
  }

  updateProduct(ProductModel product) async {
    final index = _products.indexWhere((pr) => pr.id == product.id);
    if (index < 0) return;
    _products[index] = product;
    await DBProvider.db.updateProduct(product);
    notifyListeners();
  }

  removeProduct(ProductModel product) async {
    _products.removeWhere((pr) => pr.id == product.id);
    await DBProvider.db.deleteProduct(product);
    notifyListeners();
  }
}
