import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';
import 'package:app_meals/src/screens/main/tab1_screen.dart';
import 'package:app_meals/src/screens/main/tab2_controller.dart';
import 'package:app_meals/src/screens/main/tab2_screen.dart';
import 'package:app_meals/src/screens/main/tab_main_controller.dart';
import 'package:app_meals/src/screens/main/widget/icon_order.dart';
import 'package:app_meals/src/screens/welcome/welcome_screen.dart';
import 'package:app_meals/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:app_meals/src/widgets/drawer_menu.dart';
import 'package:app_meals/src/widgets/icon_cart/icon_cart.dart';
import 'package:provider/provider.dart';

class TabMainScreen extends StatelessWidget {
  const TabMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tab1Controller = Provider.of<Tab1Controller>(context);
    final tabManController = Provider.of<TabManController>(context);
    return Scaffold(
      drawer: DraweMenu(),
      appBar: AppBar(
          title: tabManController.currentScreen == 0
              ? SelectedAddress(tab1Controller: tab1Controller)
              : Text(S.of(context).tAppBarOrders),
          actions: const [
            IconCart(),
          ]),
      body: _Screens(tabManController),
      bottomNavigationBar: const _Navigation(),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation();

  @override
  Widget build(BuildContext context) {
    final tabManController = Provider.of<TabManController>(context);
    return BottomNavigationBar(
      currentIndex: tabManController.currentScreen,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.store), label: S.of(context).tab1),
        BottomNavigationBarItem(
            icon: const IconOrder(), label: S.of(context).tab2)
      ],
      onTap: (i) {
        tabManController.currentScreen = i;
        if (i == 1) {
          Provider.of<Tab2Controller>(context, listen: false).loadOrders();
        } else if (i == 0) {
          Provider.of<Tab1Controller>(context, listen: false).load();
        }
      },
    );
  }
}

class _Screens extends StatefulWidget {
  const _Screens(this.tabManController);

  final TabManController tabManController;

  @override
  State<_Screens> createState() => _ScreensState();
}

class _ScreensState extends State<_Screens> with WidgetsBindingObserver {
  final pref = PreferencesProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => validateSession());
  }

  validateSession() async {
    Provider.of<AddressDropdownController>(context, listen: false)
        .loadAddress();
    final navigator = Navigator.of(context);
    final codeError = await widget.tabManController.checkSession();
    if (codeError == CodeError.unauthorized && !pref.isGuest) {
      PreferencesProvider().clean();
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (Route<dynamic> route) {
        return false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        validateSession();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.tabManController.pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        Tab1Screen(),
        Tab2Screen(),
      ],
    );
  }
}
