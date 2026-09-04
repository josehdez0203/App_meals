import 'dart:convert';

class AddressModel {
  AddressModel({
    this.id = 0,
    this.alias = '',
    this.address = '',
    required this.location,
  });

  int id;
  String alias;
  String address;
  Location location;

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json["id"],
        alias: json["alias"],
        address: json["address"],
        location: Location.fromJson(json["location"]),
      );

  factory AddressModel.fromJsonLocalDB(Map<String, dynamic> json) =>
      AddressModel(
        id: json["id"],
        alias: json["alias"],
        address: json["address"],
        location: Location(x: json["lt"], y: json["lg"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "alias": alias,
        "address": address,
        "location": location.toJson()
      };

  Object toHttpBody() => jsonEncode({
        "alias": alias.trim(),
        "address": address.trim(),
        "location": location.toJson()
      });
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
