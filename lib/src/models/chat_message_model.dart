import 'dart:convert';

class ChatMessageModel {
  ChatMessageModel({
    this.id = 0,
    this.type = 1,
    this.status = 1,
    required this.message,
    required this.createdAt,
    this.from,
    this.orderId,
    this.toId,
  });

  int id;
  String message;
  int type;
  int status;
  DateTime createdAt;

  From? from;
  int? orderId;
  int? toId;

  bool isSender(int clientId) {
    return from == null ? true : from!.id == clientId;
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json["id"],
        message: json["message"],
        type: json["type"],
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        from: From.fromJson(json["from"]),
      );

  Object toHttpBody(String rol) => jsonEncode({
        "message": message.trim(),
        "type": type,
        "to": {"id": toId},
        "order": {"id": orderId},
        "rol": rol
      });
}

class From {
  From({required this.id});

  int id;

  factory From.fromJson(Map<String, dynamic> json) => From(id: json["id"]);

  Map<String, dynamic> toJson() => {"id": id};
}
