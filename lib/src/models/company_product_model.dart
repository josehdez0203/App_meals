import 'dart:convert';

import 'package:app_meals/src/models/group_model.dart';

CompanyProductModel companyProductModelFromJson(String str) =>
    CompanyProductModel.fromJson(json.decode(str));

String companyProductModelToJson(CompanyProductModel data) =>
    json.encode(data.toJson());

class CompanyProductModel {
  CompanyProductModel({
    required this.id,
    this.name = '',
    this.description = '',
    this.image = '',
    this.type = 1,
    this.price = 0.0,
    this.group,
  });

  int id;
  String name;
  String description;
  String image;
  int type;
  double price;
  GroupModel? group = GroupModel(id: 0);

  factory CompanyProductModel.fromJson(Map<String, dynamic> json) =>
      CompanyProductModel(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        image: json["image"],
        type: json["type"],
        price: json["price"].toDouble(),
        group:
            json["group"] == null ? null : GroupModel.fromJson(json["group"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "type": type,
        "price": price,
      };

  Object toHttpBodyCreate(int companyId) => jsonEncode({
        "name": name.trim(),
        "description": description.trim(),
        "image": image.trim(),
        "type": type,
        "price": price,
        "company": {"id": companyId},
        "group": {"id": group!.id}
      });

  Object toHttpBodyUpdate() => jsonEncode({
        "name": name.trim(),
        "description": description.trim(),
        "image": image.trim(),
        "type": type,
        "price": price,
        "group": {"id": group!.id}
      });
}
