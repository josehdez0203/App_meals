class ChatModel {
  ChatModel({
    required this.orderId,
    required this.toUser,
    required this.label,
    required this.imageCompany,
  });

  int orderId;
  String label;
  String imageCompany;
  ToUser toUser;
}

class ToUser {
  ToUser({
    required this.id,
    required this.fullName,
    required this.image,
  });

  int id;
  String fullName;
  String image;

  factory ToUser.fromJson(Map<String, dynamic> json) => ToUser(
        id: json["id"],
        fullName: json["fullName"],
        image: json["image"],
      );
}
