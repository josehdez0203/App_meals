import 'dart:convert';

BalanceModel balanceModelFromJson(String str) =>
    BalanceModel.fromJson(json.decode(str));

String balanceModelToJson(BalanceModel data) => json.encode(data.toJson());

class BalanceModel {
  BalanceModel({
    this.userId = 0,
    this.balance = 0.0,
    this.profit = 0.0,
    this.amount = 0.0,
    this.money = 0.0,
  });

  int userId;
  double balance;
  double profit;
  double amount;
  double money;

  factory BalanceModel.fromJson(Map<String, dynamic> json) => BalanceModel(
        userId: json["userId"],
        balance: json["balance"].toDouble(),
        profit: json["profit"].toDouble(),
        amount: json["amount"].toDouble(),
        money: json["money"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "balance": balance,
        "profit": profit,
        "amount": amount,
        "money": money,
      };
}
