import 'dart:convert';

StoreCompanyModel storeCompanyModelFromJson(String str) =>
    StoreCompanyModel.fromJson(json.decode(str));

String storeCompanyModelToJson(StoreCompanyModel data) =>
    json.encode(data.toJson());

class StoreCompanyModel {
  StoreCompanyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.email,
    required this.startupCost,
    required this.costKm,
    required this.location,
    required this.sales,
    required this.createdAt,
    required this.updatedAt,
    required this.company,
  });

  int id;
  String name;
  String address;
  String contact;
  String email;
  double startupCost;
  double costKm;
  Location location;
  int sales;
  DateTime createdAt;
  DateTime updatedAt;
  Company company;

  factory StoreCompanyModel.fromJson(Map<String, dynamic> json) =>
      StoreCompanyModel(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        contact: json["contact"],
        email: json["email"],
        startupCost: json["startupCost"].toDouble(),
        costKm: json["costKm"].toDouble(),
        location: Location.fromJson(json["location"]),
        sales: json["sales"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        company: Company.fromJson(json["company"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "contact": contact,
        "email": email,
        "startupCost": startupCost,
        "costKm": costKm,
        "location": location.toJson(),
        "sales": sales,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "company": company.toJson(),
      };
}

class Company {
  Company({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.image,
    required this.marker,
    required this.email,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.categories,
  });

  int id;
  String name;
  String address;
  String contact;
  String image;
  String marker;
  String email;
  Location location;
  DateTime createdAt;
  DateTime updatedAt;
  List<CategoryElement> categories;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        contact: json["contact"],
        image: json["image"],
        marker: json["marker"],
        email: json["email"],
        location: Location.fromJson(json["location"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        categories: List<CategoryElement>.from(
            json["categories"].map((x) => CategoryElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "contact": contact,
        "image": image,
        "marker": marker,
        "email": email,
        "location": location.toJson(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class CategoryElement {
  CategoryElement({
    required this.id,
    required this.updatedAt,
    required this.category,
  });

  int id;
  DateTime updatedAt;
  CategoryCategory category;

  factory CategoryElement.fromJson(Map<String, dynamic> json) =>
      CategoryElement(
        id: json["id"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        category: CategoryCategory.fromJson(json["category"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "updatedAt": updatedAt.toIso8601String(),
        "category": category.toJson(),
      };
}

class CategoryCategory {
  CategoryCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  String image;
  DateTime createdAt;
  DateTime updatedAt;

  factory CategoryCategory.fromJson(Map<String, dynamic> json) =>
      CategoryCategory(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Location {
  Location({
    required this.x,
    required this.y,
  });

  double x;
  double y;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        x: json["x"].toDouble(),
        y: json["y"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}
