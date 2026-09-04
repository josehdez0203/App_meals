import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/address_model.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.image,
    required this.roles,
    required this.token,
    required this.addresses,
  });

  int id;
  String email;
  String fullName;
  String phone;
  String image;
  List<String> roles;
  String token;
  List<AddressModel> addresses;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        email: json["email"],
        fullName: json["fullName"],
        phone: json["phone"] ?? 's/n',
        image: json["image"].toString().length <= 10
            ? kImageClientDefault
            : json["image"],
        roles: List<String>.from(json["roles"].map((x) => x)),
        token: json["token"] ?? '',
        addresses: json["addresses"] == null
            ? []
            : List<AddressModel>.from(
                json["addresses"].map((x) => AddressModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "fullName": fullName,
        "phone": phone,
        "image": image,
        "roles": List<dynamic>.from(roles.map((x) => x)),
        "token": token,
      };
}
