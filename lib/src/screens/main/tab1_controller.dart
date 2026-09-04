import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/models/category_model.dart';
import 'package:app_meals/src/models/company_model.dart';
import 'package:app_meals/src/models/market_companies_response.dart';
import 'package:app_meals/src/models/product_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/services/market_service.dart';

class Tab1Controller with ChangeNotifier {
  List<CompanyModel> companies = [];
  List<ProductModel> products = [];
  List<CategoryModel> categories = [];

  bool _inAsyncCall = false;

  MarketService marketService = MarketService();

  CategoryModel _selectedCategory =
      CategoryModel(id: 0, name: 'All', image: kImageCategoryAll);

  Tab1Controller() {
    categories.add(_selectedCategory);
    load();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  CategoryModel get selectedCategory => _selectedCategory;

  set selectedCategory(category) {
    _selectedCategory = category;
    loadCompanies();
  }

  load() async {
    loadCategories();
    loadCompanies();
  }

  loadCompanies({String filter = ''}) async {
    AddressModel? address = await DBProvider.db.loadAddress();
    if (address == null) return;

    inAsyncCall = true;

    MarketCompaniesResponse response = await marketService.getCompanies(
        selectedCategory, address.location.x, address.location.y,
        filter: filter);

    final List<ProductModel> productsCart =
        await DBProvider.db.loadProducts(TypesCompany.store);
    for (var product in response.products) {
      final int index = productsCart
          .indexWhere((productCart) => productCart.id == product.id);
      if (index >= 0) product.isInCart = true;
    }

    products = response.products;
    companies = response.companies;
    inAsyncCall = false;
  }

  DateTime fecha2 = DateTime.now();

  filterCompanies(String filter) {
    fecha2 = DateTime.now();
    Future.delayed(
      const Duration(milliseconds: 1100),
      () => evaluate(filter),
    );
  }

  evaluate(String filter) {
    Duration duration = DateTime.now().difference(fecha2);
    if (duration > const Duration(milliseconds: 1100)) {
      loadCompanies(filter: filter.trim());
    }
  }

  loadCategories() async {
    AddressModel? address = await DBProvider.db.loadAddress();
    if (address == null) return;

    categories = await marketService.getCategories(
        address.location.x, address.location.y);
    categories.insert(
        0, CategoryModel(id: 0, name: 'All', image: kImageCategoryAll));
  }

  setProducts(ProductModel product) {
    final index = products.indexWhere((pr) => pr.id == product.id);
    if (index < 0) return;
    products[index] = product;
    notifyListeners();
  }
}
