import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/src/services/credit_service.dart';

class CreditController with ChangeNotifier {
  final CreditService creditService = CreditService();

  String _phone = '';
  double _amount = 0.0;
  bool _inAsyncCall = false;

  String get phone => _phone;

  set phone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  double get amount => _amount;

  set amount(double amount) {
    _amount = amount;
    notifyListeners();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  Future<int> topUpBalance() async {
    inAsyncCall = true;
    Map<String, dynamic>? decodedResp =
        await creditService.topUpBalance(phone, amount);
    inAsyncCall = false;
    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('balance')) {
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unknown;
  }
}
