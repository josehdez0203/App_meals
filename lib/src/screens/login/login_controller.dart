import 'package:flutter/material.dart';

class LoginController with ChangeNotifier {
  final PageController _pageController = PageController();

  int _currentScreen = 0;

  PageController get pageController => _pageController;

  int get currentScreen => _currentScreen;

  set currentScreen(int current) {
    _currentScreen = current;
    if (pageController.hasClients) {
      pageController.animateToPage(current,
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    }
    notifyListeners();
  }
}
