import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/request/request_controller.dart';
import 'package:app_meals/src/screens/manager/request/widget/details_products.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';

class FloatingSheetBottom extends StatelessWidget {
  final RequestController requestController;

  const FloatingSheetBottom({super.key, required this.requestController})
      ;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.2,
      maxChildSize: 1,
      snap: true,
      snapSizes: const [0.4, 0.85, 1],
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
                    height: 70,
                    child: ClipOval(
                        child: AvatarImage(
                            image:
                                requestController.request.store.company.image)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Icon(
                      requestController.request.payment == TypesPayment.money
                          ? Icons.credit_score_outlined
                          : Icons.payments_outlined,
                      color: kErrorColor),
                  const SizedBox(width: kDefaultPadding * 0.5),
                  Text(
                      requestController.request.payment == TypesPayment.money
                          ? S.of(context).lPayMoney
                          : S.of(context).lPayCash,
                      style: const TextStyle(color: kErrorColor)),
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                  Text(
                      '${S.of(context).lTotal} ${requestController.request.total.toStringAsFixed(kCoinDecimals)} $kCoin'),
                  const SizedBox(width: 10)
                ],
              ),
              const SizedBox(height: 10),
              DetailsProducts(request: requestController.request),
            ],
          ),
        ),
      ),
    );
  }
}
