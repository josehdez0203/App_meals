import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/src/models/company_product_model.dart';
import 'package:app_meals/src/services/store_manager_service.dart';

class ProductController extends ChangeNotifier {
  final StoreManagerService storeManagerService = StoreManagerService();

  CompanyProductModel _companyProduct = CompanyProductModel(id: 0);

  CompanyProductModel get companyProduct => _companyProduct;

  set companyProduct(CompanyProductModel companyProduct) {
    _companyProduct = companyProduct;
    notifyListeners();
  }

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  Future<CompanyProductModel?> updateProduct(int companyId) async {
    inAsyncCall = true;

    CompanyProductModel? productResponse;
    if (companyProduct.id > 0) {
      productResponse = await storeManagerService.updateProduct(companyProduct);
    } else {
      productResponse =
          await storeManagerService.createProduct(companyProduct, companyId);
    }

    if (productResponse == null) {
      inAsyncCall = false;
      return null;
    }
    inAsyncCall = false;
    return productResponse;
  }
}
