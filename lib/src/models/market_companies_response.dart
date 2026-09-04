import 'package:app_meals/src/models/company_model.dart';
import 'package:app_meals/src/models/product_model.dart';

class MarketCompaniesResponse {
  MarketCompaniesResponse({
    required this.companies,
    required this.products,
  });

  List<CompanyModel> companies;
  List<ProductModel> products;

  factory MarketCompaniesResponse.fromJson(Map<String, dynamic> json) =>
      MarketCompaniesResponse(
        companies: List<CompanyModel>.from(
            json["companies"].map((x) => CompanyModel.fromJson(x))),
        products: List<ProductModel>.from(
            json["products"].map((x) => ProductModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "companies": List<dynamic>.from(companies.map((x) => x.toJson())),
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
      };
}
