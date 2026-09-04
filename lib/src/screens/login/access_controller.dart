import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/src/models/user_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/services/auth_service.dart';

class AccessController with ChangeNotifier {
  final AuthService authService = AuthService();
  final prefs = PreferencesProvider();

  String _fullName = '';
  String _email = '';
  String _password = '';
  String _phone = '';
  bool _inAsyncCall = false;

  String get email => _email;

  set email(String email) {
    _email = email;
    notifyListeners();
  }

  String get fullName => _fullName;

  set fullName(String fullName) {
    _fullName = fullName;
    notifyListeners();
  }

  String get password => _password;

  set password(String password) {
    _password = password;
    notifyListeners();
  }

  String get phone => _phone;

  set phone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  Future<UserModel?> signin() async {
    inAsyncCall = true;
    UserModel? user = await authService.login(email, password);
    inAsyncCall = false;
    if (user == null) return user;

    if (user.addresses.isNotEmpty) {
      await DBProvider.db.createAddress(user.addresses.first);
    }
    prefs.user = user;
    prefs.token = user.token;
    return user;
  }

  Future<int> signup() async {
    inAsyncCall = true;
    Map<String, dynamic>? decodedResp =
        await authService.register(email, password, fullName, phone);
    inAsyncCall = false;
    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('user')) {
      UserModel user = UserModel.fromJson(decodedResp['user']);
      if (user.addresses.isNotEmpty) {
        inAsyncCall = true;
        await DBProvider.db.createAddress(user.addresses.first);
        inAsyncCall = false;
      }
      prefs.user = user;
      prefs.token = user.token;
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unknown;
  }
}
