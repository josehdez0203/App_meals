import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/requests/requests_controller.dart';
import 'package:app_meals/src/screens/manager/requests/widget/content_requests.dart';
import 'package:app_meals/src/widgets/drawer_menu.dart';
import 'package:provider/provider.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requestsController = Provider.of<RequestsController>(context);
    return Scaffold(
      drawer: DraweMenu(),
      appBar: AppBar(
        title: requestsController.currentScreen == 0
            ? Text(S.of(context).tRequests)
            : Text(S.of(context).tRequestsHistory),
      ),
      body: ContentRequests(requestsController: requestsController),
      bottomNavigationBar: const _Navigation(),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation();

  @override
  Widget build(BuildContext context) {
    final requestsController = Provider.of<RequestsController>(context);
    return BottomNavigationBar(
      currentIndex: requestsController.currentScreen,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.electric_bike),
            label: S.of(context).tRequests),
        BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            label: S.of(context).tRequestsHistory),
      ],
      onTap: (i) {
        requestsController.currentScreen = i;
        if (i == 1) {
          requestsController.selectedDay = DateTime.now();
        } else {
          requestsController.loadRequests();
        }
      },
    );
  }
}
