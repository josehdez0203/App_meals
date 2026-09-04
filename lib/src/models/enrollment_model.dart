import 'dart:convert';

EnrollmentModel enrollmentModelFromJson(String str) =>
    EnrollmentModel.fromJson(json.decode(str));

String enrollmentModelToJson(EnrollmentModel data) =>
    json.encode(data.toJson());

class EnrollmentModel {
  EnrollmentModel({
    this.name = '',
    this.address = '',
    this.contact = '',
    this.image = '',
    this.marker = '',
    this.email = '',
    required this.location,
  });

  String name;
  String address;
  String contact;
  String image;
  String marker;
  String email;
  Location location;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentModel(
        name: json["name"],
        address: json["address"],
        contact: json["contact"],
        image: json["image"],
        marker: json["marker"],
        email: json["email"],
        location: Location.fromJson(json["location"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
        "contact": contact,
        "image": image,
        "marker": marker,
        "email": email,
        "location": location.toJson(),
      };

  Object toHttpBodyEnrollment(int categoryId) => jsonEncode({
        "name": name.trim(),
        "address": address.trim(),
        "contact": contact.trim(),
        "marker": marker.trim(),
        "image": image.trim(),
        "email": email.trim(),
        "location": location.toJson(),
        "categoryId": categoryId
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
