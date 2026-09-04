import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/src/models/balance_model.dart';
import 'package:app_meals/src/models/user_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/services/auth_service.dart';
import 'package:app_meals/src/services/balance_service.dart';

class ProfileController with ChangeNotifier {
  final AuthService authService = AuthService();
  final prefs = PreferencesProvider();

  String _fullName = '';
  String _email = '';
  String _password = '';
  String _phone = '';
  String olpPhone = '';
  bool _inAsyncCall = false;

  ProfileController() {
    _fullName = prefs.user.fullName;
    _email = prefs.user.email;
    olpPhone = prefs.user.phone;

    loadBalance();
  }

  BalanceModel _balance = BalanceModel();

  BalanceModel get balance => _balance;

  set balance(BalanceModel balance) {
    _balance = balance;
    notifyListeners();
  }

  final BalanceService balanceService = BalanceService();

  loadBalance() async {
    BalanceModel? balanceResponse = await balanceService.getBalance();
    if (balanceResponse == null) return;
    balance = balanceResponse;
  }

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

  Future<bool> logOut() async {
    return await authService.logOut();
  }

  Future<int> update() async {
    inAsyncCall = true;
    Map<String, dynamic>? decodedResp =
        await authService.update(email, fullName, phone);
    inAsyncCall = false;

    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('user')) {
      prefs.user = UserModel.fromJson(decodedResp['user']);
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unknown;
  }

  Future<bool> updatePasswor() async {
    inAsyncCall = true;
    bool isUpdated = await authService.updatePasswor(password);
    inAsyncCall = false;
    return isUpdated;
  }

  Future<int> changeImage(String image) async {
    Map<String, dynamic>? decodedResp = await authService.changeImage(image);
    inAsyncCall = false;

    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('user')) {
      prefs.user = UserModel.fromJson(decodedResp['user']);
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unknown;
  }
}
