import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:app_meals/src/screens/main/tab2_controller.dart';
import 'package:provider/provider.dart';

class IconOrder extends StatelessWidget {
  const IconOrder({
    super.key,
  }) ;

  @override
  Widget build(BuildContext context) {
    final tab2Controller = Provider.of<Tab2Controller>(context);
    if (tab2Controller.numOrders <= 0) {
      return const Icon(Icons.electric_bike);
    }
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -20, end: -20),
      badgeContent: Text(
        tab2Controller.numOrders.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      child: const Icon(Icons.electric_bike),
    );
  }
}
