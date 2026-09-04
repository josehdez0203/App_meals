import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/common/status_label.dart';
import 'package:app_meals/src/models/order_model.dart';
import 'package:app_meals/src/screens/order/order_screen.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/card_notifications_icon.dart';

class ListOrder extends StatelessWidget {
  final List<OrderModel> orders;

  const ListOrder(this.orders, {super.key}) ;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) => _Order(orders[index]),
    );
  }
}

class _Order extends StatelessWidget {
  final OrderModel order;
  final double height = 150;

  const _Order(this.order);

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _card(BuildContext context) {
    final card = SizedBox(
      height: height,
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            AvatarImage(image: order.store.company.image),
            Expanded(
              child: Container(
                height: height,
                padding: const EdgeInsets.only(left: 10.0, top: 3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 30.0),
                    Text(statusOrderLabel(
                      order.status,
                      order.store.company.type,
                    )),
                    Expanded(child: Container()),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        Text(
                            '${(order.total).toStringAsFixed(kCoinDecimals)} $kCoin',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 15.0),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withValues(alpha: (0.6 * 255)),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderScreen(order)));
                }),
          ),
        ),
        CardNotificationsIcon(
          notifications: order.notificationsClient,
          status: order.status,
        )
      ],
    );
  }
}
