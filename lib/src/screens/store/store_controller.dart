import 'package:flutter/material.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/models/company_model.dart';
import 'package:app_meals/src/models/fee_model.dart';
import 'package:app_meals/src/models/group_model.dart';
import 'package:app_meals/src/models/market_products_response.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/services/market_service.dart';

class StoreController with ChangeNotifier {
  final MarketService marketService = MarketService();

  late CompanyModel _company;
  bool _inAsyncCall = false;
  double _deliveryFee = 0.0;
  final List<ProductModel> _products = [];

  GroupModel _groupSelected = GroupModel(id: 0);
  final List<GroupModel> _groups = [];

  CompanyModel get company => _company;

  set company(CompanyModel company) {
    _company = company;
    _groupSelected = GroupModel(id: 0);
    loadProducts();
    loadDeliveryFeed();
  }

  GroupModel get groupSelected => _groupSelected;

  set groupSelected(GroupModel groupSelected) {
    _groupSelected = groupSelected;
    loadProducts();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  double get deliveryFee => _deliveryFee;

  set deliveryFee(double cost) {
    _deliveryFee = cost;
    notifyListeners();
  }

  List<ProductModel> get products => _products;

  List<GroupModel> get groups => _groups;

  set groups(List<GroupModel> groups) {
    _groups.clear();
    _groups.addAll(groups);
    notifyListeners();
  }

  setProducts(ProductModel product) {
    final index = _products.indexWhere((pr) => pr.id == product.id);
    if (index < 0) return;
    _products[index] = product;
    notifyListeners();
  }

  loadDeliveryFeed() async {
    AddressModel? address = await DBProvider.db.loadAddress();
    if (address == null) {
      return;
    }
    List<FeeModel> fees = await marketService.deliveryCost(
        company.id.toString(), address.location.x, address.location.y);
    int index = fees.indexWhere((fee) => fee.storeId == company.storeId);
    if (index < 0) return;
    deliveryFee = fees[index].deliveryfee;
  }

  loadProducts() async {
    products.clear();
    inAsyncCall = true;

    MarketProductsResponse marketProductsResponse =
        await marketService.getProducts(company.id, groupSelected.id);

    if (groupSelected.id == 0) {
      groups = marketProductsResponse.groups;
    }

    final List<ProductModel> productsCart =
        await DBProvider.db.loadProducts(company.type);
    for (var product in marketProductsResponse.products) {
      int index = productsCart
          .indexWhere((productCart) => productCart.id == product.id);
      if (index >= 0) {
        product.isInCart = true;
      }
      products.add(product);
    }
    inAsyncCall = false;
    notifyListeners();
  }
}
