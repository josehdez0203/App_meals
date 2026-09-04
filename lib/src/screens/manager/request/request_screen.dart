import 'package:flutter/material.dart';
import 'package:app_meals/src/models/request_model.dart';
import 'package:app_meals/src/screens/manager/request/request_controller.dart';
import 'package:app_meals/src/screens/manager/request/widget/content_request.dart';
import 'package:provider/provider.dart';

class RequestScreen extends StatelessWidget {
  final RequestModel request;

  const RequestScreen(this.request, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RequestController>.value(
      value: RequestController(request),
      child: Consumer<RequestController>(
        builder: (context, requestController, child) =>
            ContentRequest(requestController),
      ),
    );
  }
}
