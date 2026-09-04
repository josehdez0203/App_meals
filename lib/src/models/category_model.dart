class CategoryModel {
  CategoryModel({
    required this.id,
    this.name = '',
    this.image = '',
  });

  int id;
  String name;
  String image;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}
