class FeeModel {
  FeeModel({
    required this.name,
    required this.marker,
    required this.image,
    required this.storeId,
    required this.companyId,
    required this.deliveryfee,
    required this.fromlt,
    required this.fromlg,
  });

  String name;
  String marker;
  String image;
  int storeId;
  int companyId;
  double deliveryfee;

  double fromlt;
  double fromlg;

  factory FeeModel.fromJson(Map<String, dynamic> json) => FeeModel(
        name: json["name"],
        marker: json["marker"],
        image: json["image"],
        storeId: json["store_id"],
        companyId: json["companyId"],
        deliveryfee: json["deliveryfee"].toDouble(),
        fromlt: double.parse(json["fromlt"].toString()),
        fromlg: double.parse(json["fromlg"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "marker": marker,
        "image": image,
        "storeId": storeId,
        "companyId": companyId,
        "deliveryfee": deliveryfee,
      };
}
