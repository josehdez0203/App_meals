import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/src/services/auth_service.dart';

class RecoverController extends ChangeNotifier {
  final AuthService authService = AuthService();

  String email = '';

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  Future<int> recover() async {
    Map<String, dynamic>? decodedResp = await authService.recover(email);
    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('recover')) {
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unknown;
  }
}
