import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/models/request_model.dart';
import 'package:app_meals/src/provider/push_provider.dart';
import 'package:app_meals/src/services/auth_service.dart';
import 'package:app_meals/src/services/request_service.dart';

class RequestsController with ChangeNotifier {
  final AuthService authService = AuthService();
  final RequestService requestService = RequestService();

  final _pushProvider = PushProvider();

  late bool _isOnline;
  int _currentScreen = 0;
  DateTime _selectedDay = DateTime.now();

  int get currentScreen => _currentScreen;

  set currentScreen(int current) {
    _currentScreen = current;
    notifyListeners();
  }

  DateTime get selectedDay => _selectedDay;

  set selectedDay(DateTime selectedDay) {
    _selectedDay = selectedDay;
    _requests.clear();
    loadRequests();
    notifyListeners();
  }

  RequestsController() {
    loadRequests();
    _pushProvider.notifications.listen(evaluateNotification);
  }

  evaluateNotification(Map<String, dynamic> notification) async {
    switch (notification['type']) {
      case TypesNotification.newOrder:
        final int newOrderId = int.parse(notification['orderId'].toString());
        final indexOrder =
            _requests.indexWhere((request) => request.id == newOrderId);
        if (indexOrder < 0) {
          _requests = await requestService.findNearRequests();
          notifyListeners();
        }
        break;
      case TypesNotification.messageChat:
        final orderId = int.parse(notification['orderId']);
        final index = _requests.indexWhere((or) => or.id == orderId);
        if (index < 0) return;
        _requests[index].notificationsDeliveryman++;
        notifyListeners();
        break;
      default:
    }
  }

  bool get isOnline => _isOnline;

  set isOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  loadRequests() async {
    inAsyncCall = true;
    if (currentScreen == 0) {
      _requests = await requestService.findNearRequests();
    } else {
      String orderedAt = selectedDay.toString().split(' ')[0];
      _requests = await requestService.history(orderedAt);
    }
    inAsyncCall = false;
    notifyListeners();
  }

  List<RequestModel> _requests = [];

  get requests => _requests;

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  Future<int> checkSession() async {
    Map<String, dynamic>? decodedResp = await authService.check();
    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('user')) {
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unauthorized;
  }

  removeOrder(RequestModel request) {
    final index = _requests.indexWhere((pr) => pr.id == request.id);
    if (index < 0) return;
    _requests.removeAt(index);
    notifyListeners();
  }
}
