import 'package:flutter/material.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/models/order_model.dart';
import 'package:app_meals/src/provider/push_provider.dart';
import 'package:app_meals/src/services/market_service.dart';

class Tab2Controller with ChangeNotifier {
  final _pushProvider = PushProvider();
  MarketService marketService = MarketService();

  bool _inAsyncCall = false;

  int _numOrders = 0;

  List<OrderModel> orders = [];

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  int get numOrders => _numOrders;

  set numOrders(int newValue) {
    _numOrders = newValue;
    notifyListeners();
  }

  Tab2Controller() {
    loadOrders();
    _pushProvider.notifications.listen(evaluateNotification);
  }

  evaluateNotification(Map<String, dynamic> notification) async {
    switch (notification['type']) {
      case TypesNotification.changeOrderStatust:
        loadOrders();
        break;
      case TypesNotification.messageChat:
        final orderId = int.parse(notification['orderId']);
        final index = orders.indexWhere((or) => or.id == orderId);
        if (index < 0) return;
        orders[index].notificationsClient++;
        notifyListeners();
        break;
      default:
    }
  }

  cleanNotificationsClient(int orderId) {
    final index = orders.indexWhere((or) => or.id == orderId);
    if (index < 0) return;
    orders[index].notificationsClient = 0;
    notifyListeners();
  }

  loadOrders() async {
    inAsyncCall = true;
    orders = await marketService.getOrders();
    numOrders = orders.length;
    inAsyncCall = false;
    notifyListeners();
  }
}
