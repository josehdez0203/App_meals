import 'dart:convert';

GroupModel groupFromJson(String str) => GroupModel.fromJson(json.decode(str));

String groupToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel {
  GroupModel({
    required this.id,
    this.name = '',
  });

  int id;
  String name;

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json["id"],
        name: json["name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
