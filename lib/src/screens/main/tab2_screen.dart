import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/main/tab2_controller.dart';
import 'package:app_meals/src/screens/main/widget/list_order.dart';
import 'package:app_meals/src/widgets/image_is_empty.dart';
import 'package:app_meals/src/widgets/label.dart';
import 'package:provider/provider.dart';

class Tab2Screen extends StatefulWidget {
  const Tab2Screen({super.key});

  @override
  State<Tab2Screen> createState() => _Tab2ScreenState();
}

class _Tab2ScreenState extends State<Tab2Screen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Provider.of<Tab2Controller>(context, listen: false).loadOrders();
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
    final tab2Controller = Provider.of<Tab2Controller>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: tab2Controller.inAsyncCall,
          child: const LinearProgressIndicator(),
        ),
        Label(S.of(context).tOrders, S.of(context).sTOrders),
        tab2Controller.orders.isEmpty && !tab2Controller.inAsyncCall
            ? ImageIsEmpty('assets/screen/tab2.png',
                message: S.of(context).emptyTab2)
            : Expanded(child: ListOrder(tab2Controller.orders)),
      ],
    );
  }
}
