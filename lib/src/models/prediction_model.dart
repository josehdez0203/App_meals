class PredictionModel {
  PredictionModel({
    required this.description,
    required this.placeId,
  });

  String description;
  String placeId;

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      PredictionModel(
        description: json["description"],
        placeId: json["place_id"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "place_id": placeId,
      };
}
