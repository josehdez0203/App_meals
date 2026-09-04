import 'package:app_meals/constants/constants.dart';

class OrderModel {
  OrderModel({
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
    required this.store,
    required this.notificationsClient,
    required this.payment,
    this.deliveryman,
    this.scoreClient = 5,
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
  Store store;
  int notificationsClient;
  int payment;
  Deliveryman? deliveryman;
  double scoreClient;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
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
        store: Store.fromJson(json["store"]),
        notificationsClient: json["notificationsClient"],
        payment: json["payment"],
        deliveryman: json["deliveryman"] == null
            ? Deliveryman(
                id: 0, fullName: kNameApp, image: kImageDeliveryManDefault)
            : Deliveryman.fromJson(json["deliveryman"]),
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
        "notificationsClient": notificationsClient,
        "store": store.toJson(),
        "payment": payment,
        "deliveryman": deliveryman ?? deliveryman!.toJson(),
        "scoreClient": scoreClient,
      };
}

class Deliveryman {
  Deliveryman({
    required this.id,
    required this.fullName,
    required this.image,
  });

  int id;
  String fullName;
  String image;

  factory Deliveryman.fromJson(Map<String, dynamic> json) => Deliveryman(
        id: json["id"],
        fullName: json["fullName"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
        "image": image,
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
  });

  int id;
  String name;
  String description;
  double price;
  String image;
  int number;
  double total;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"].toDouble(),
        image: json["image"],
        number: json["number"],
        total: json["total"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image": image,
        "number": number,
        "total": total,
      };
}

class Store {
  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.company,
  });

  int id;
  String name;
  String address;
  Company company;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        company: Company.fromJson(json["company"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "company": company.toJson(),
      };
}

class Company {
  Company({
    required this.image,
    required this.marker,
    required this.type,
  });

  String image;
  String marker;
  int type;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        image: json["image"],
        marker: json["marker"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "marker": marker,
        "type": type,
      };
}
