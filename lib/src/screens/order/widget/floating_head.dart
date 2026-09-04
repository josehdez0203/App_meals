import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/status_label.dart';
import 'package:app_meals/src/screens/order/order_controller.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';

class FloatingHead extends StatelessWidget {
  const FloatingHead({
    super.key,
    required this.orderController,
  }) ;

  final OrderController orderController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: orderController.centerMap,
              child: ClipOval(
                  child: AvatarImage(
                      image: orderController.order.deliveryman!.image)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      '${S.of(context).lOrderBy}: ${orderController.order.deliveryman!.fullName}',
                      maxLines: 1,
                      overflow: TextOverflow.visible),
                  const SizedBox(height: 5),
                  Text(
                      statusOrderLabel(
                        orderController.order.status,
                        orderController.order.store.company.type,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
