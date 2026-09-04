import 'package:app_meals/constants/constants.dart';

class PetitionModel {
  PetitionModel({
    required this.id,
    required this.note,
    required this.address,
    required this.status,
    required this.products,
    required this.deliveryFee,
    required this.total,
    required this.start,
    required this.location,
    required this.createdAt,
    required this.user,
    required this.store,
    required this.notificationsDeliveryman,
    required this.payment,
    this.scoreDeliveryman = 5,
  });

  int id;
  String note;
  String address;
  int status;
  List<Product> products;
  double deliveryFee;
  double total;
  Location start;
  Location location;
  DateTime createdAt;
  User user;
  Store store;
  int notificationsDeliveryman;
  int payment;
  double scoreDeliveryman;

  factory PetitionModel.fromJson(Map<String, dynamic> json) => PetitionModel(
        id: json["id"],
        note: json["note"],
        address: json["address"],
        status: json["status"],
        products: List<Product>.from(
            json["products"].map((x) => Product.fromJson(x))),
        deliveryFee: json["deliveryFee"].toDouble(),
        total: json["total"].toDouble(),
        start: Location.fromJson(json["start"]),
        location: Location.fromJson(json["location"]),
        createdAt: DateTime.parse(json["createdAt"]),
        user: User.fromJson(json["user"]),
        store: Store.fromJson(json["store"]),
        payment: json["payment"],
        notificationsDeliveryman: json["notificationsDeliveryman"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "note": note,
        "address": address,
        "status": status,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "deliveryFee": deliveryFee,
        "total": total,
        "start": start.toJson(),
        "location": location.toJson(),
        "createdAt": createdAt.toIso8601String(),
        "user": user.toJson(),
        "store": store.toJson(),
        "notificationsDeliveryman": notificationsDeliveryman,
        "payment": payment,
        "scoreDeliveryman": scoreDeliveryman,
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

class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.number,
    required this.total,
    required this.note,
  });

  int id;
  String name;
  String description;
  double price;
  String image;
  int number;
  double total;
  String note;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"].toDouble(),
        image: json["image"],
        number: json["number"],
        total: json["total"].toDouble(),
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image": image,
        "number": number,
        "total": total,
        "note": note,
      };

  @override
  String toString() {
    String nota = note.isEmpty ? '' : ' ($note) ';
    return '[$number] $name $nota${price.toStringAsFixed(kCoinDecimals)} $kCoin';
  }
}

class Store {
  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    // required this.location,
    required this.company,
  });

  int id;
  String name;
  String address;
  String contact;

  // Location location;
  Company company;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        contact: json["contact"],
        // location: Location.fromJson(json["location"]),
        company: Company.fromJson(json["company"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "contact": contact,
        // "location": location.toJson(),
        "company": company.toJson(),
      };
}

class Company {
  Company({
    required this.image,
  });

  String image;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
      };
}

class User {
  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.image,
  });

  int id;
  String fullName;
  dynamic phone;
  String image;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        fullName: json["fullName"],
        phone: json["phone"] ?? 's/n',
        image: json["image"].toString().length <= 10
            ? kImageClientDefault
            : json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
        "phone": phone,
        "image": image,
      };
}
