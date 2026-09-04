import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/status_constant.dart';

class IconStatusOrder extends StatelessWidget {
  const IconStatusOrder(
    this.status, {
    super.key,
  }) ;
  final int status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case StatusOrder.started:
        return const Icon(Icons.access_time_outlined, color: kSecondaryColor);
      case StatusOrder.assigned:
        return const Icon(Icons.delivery_dining_outlined,
            color: kSecondaryColor);
      case StatusOrder.taken:
        return const Icon(Icons.real_estate_agent_outlined, color: kErrorColor);
      case StatusOrder.delivered:
        return const Icon(Icons.star_border_outlined, color: kErrorColor);
      case StatusOrder.cancelled:
        return const Icon(Icons.heart_broken_outlined, color: kErrorColor);
      default:
        return const Icon(Icons.whatshot_outlined, color: kPrimaryColor);
    }
  }
}
