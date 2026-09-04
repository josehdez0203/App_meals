import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/src/services/auth_service.dart';

class TabManController with ChangeNotifier {
  final AuthService authService = AuthService();
  final PageController _pageController = PageController();

  int _currentScreen = 0;

  PageController get pageController => _pageController;

  int get currentScreen => _currentScreen;

  set currentScreen(int current) {
    _currentScreen = current;

    _pageController.animateToPage(current,
        duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
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
}
