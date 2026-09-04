import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/status_constant.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/chat_model.dart';
import 'package:app_meals/src/screens/chat/chat_screen.dart';
import 'package:app_meals/src/screens/main/tab2_controller.dart';
import 'package:app_meals/src/screens/order/order_controller.dart';
import 'package:app_meals/src/screens/order/widget/info_product.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/sheet_chat_icon.dart';
import 'package:provider/provider.dart';

class FloatingSheetBottom extends StatelessWidget {
  final OrderController orderController;

  const FloatingSheetBottom({super.key, required this.orderController})
      ;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 1,
      snap: true,
      snapSizes: const [0.7, 1],
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 10),
        color: Colors.white,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                  child: SizedBox(width: 60, child: Divider(thickness: 5))),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    width: 80,
                    child: orderController.order.status >=
                                StatusOrder.assigned &&
                            orderController.order.status <= StatusOrder.taken
                        ? IconChat(orderController)
                        : Container(),
                  ),
                  SizedBox(
                    height: 70,
                    child: ClipOval(
                        child: AvatarImage(
                            image: orderController.order.store.company.image)),
                  ),
                  const SizedBox(width: 80),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Icon(
                      orderController.order.payment == TypesPayment.money
                          ? Icons.credit_score_outlined
                          : Icons.payments_outlined,
                      color: kErrorColor),
                  const SizedBox(width: kDefaultPadding * 0.5),
                  Text(
                      orderController.order.payment == TypesPayment.money
                          ? S.of(context).lPayMoney
                          : S.of(context).lPayCash,
                      style: const TextStyle(color: kErrorColor)),
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                  Text(
                      '${S.of(context).lTotal} ${orderController.order.total.toStringAsFixed(kCoinDecimals)} $kCoin'),
                  const SizedBox(width: 10)
                ],
              ),
              const SizedBox(height: 10),
              InfoProduct(order: orderController.order),
            ],
          ),
        ),
      ),
    );
  }
}

class IconChat extends StatelessWidget {
  const IconChat(
    this.orderController, {
    super.key,
  }) ;

  final OrderController orderController;

  @override
  Widget build(BuildContext context) {
    return SheetChatIcon(
        notifications: orderController.order.notificationsClient,
        goToChatScreen: _goToChatScreen);
  }

  _goToChatScreen(BuildContext context) {
    orderController.cleanNotificationsClient();
    Provider.of<Tab2Controller>(context, listen: false)
        .cleanNotificationsClient(orderController.order.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatModel: ChatModel(
            orderId: orderController.order.id,
            toUser:
                ToUser.fromJson(orderController.order.deliveryman!.toJson()),
            label: S.of(context).lDeliveryman,
            imageCompany: orderController.order.store.company.image,
          ),
          myRol: TypesRol.client,
        ),
      ),
    );
  }
}
