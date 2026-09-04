import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/status_constant.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/launch.dart';
import 'package:app_meals/src/models/chat_model.dart';
import 'package:app_meals/src/screens/chat/chat_screen.dart';
import 'package:app_meals/src/screens/deliveryman/petition/petition_controller.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/details_products.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/sheet_chat_icon.dart';
import 'package:provider/provider.dart';

class FloatingSheetBottom extends StatelessWidget {
  final PetitionController petitionController;

  const FloatingSheetBottom({super.key, required this.petitionController})
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
                    child: _chatClient(context),
                  ),
                  SizedBox(
                    height: 70,
                    child: ClipOval(
                        child: AvatarImage(
                            image: petitionController
                                .petition.store.company.image)),
                  ),
                  SizedBox(
                    width: 80,
                    child: _callClient(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Icon(
                      petitionController.petition.payment == TypesPayment.money
                          ? Icons.credit_score_outlined
                          : Icons.payments_outlined,
                      color: kErrorColor),
                  const SizedBox(width: kDefaultPadding * 0.5),
                  Text(
                      petitionController.petition.payment == TypesPayment.money
                          ? S.of(context).lPayMoney
                          : S.of(context).lPayCash,
                      style: const TextStyle(color: kErrorColor)),
                  Expanded(child: Container()),
                  Text(
                      '${S.of(context).lTotal} ${petitionController.petition.total.toStringAsFixed(kCoinDecimals)} $kCoin'),
                  const SizedBox(width: 10)
                ],
              ),
              const SizedBox(height: 10),
              DetailsProducts(petition: petitionController.petition),
            ],
          ),
        ),
      ),
    );
  }

  Widget _callClient() {
    if (petitionController.petition.status >= StatusOrder.assigned &&
        petitionController.petition.status <= StatusOrder.taken) {
      return IconButton(
        onPressed: () => call(petitionController.petition.user.phone),
        icon: const Icon(
          Icons.quick_contacts_dialer_outlined,
          color: kPrimaryColor,
          size: 35,
        ),
      );
    }
    return Container();
  }

  Widget _chatClient(BuildContext context) {
    if (petitionController.petition.status >= StatusOrder.assigned &&
        petitionController.petition.status <= StatusOrder.taken) {
      return IconChat(petitionController);
    }
    return Container();
  }
}

class IconChat extends StatelessWidget {
  const IconChat(
    this.petitionController, {
    super.key,
  }) ;

  final PetitionController petitionController;

  @override
  Widget build(BuildContext context) {
    return SheetChatIcon(
        notifications: petitionController.petition.notificationsDeliveryman,
        goToChatScreen: _goToChatScreen);
  }

  _goToChatScreen(BuildContext context) {
    petitionController.cleanNotificationsClient();
    Provider.of<PetitionsController>(context, listen: false)
        .cleanNotificationsDeliveryman(petitionController.petition.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatModel: ChatModel(
            orderId: petitionController.petition.id,
            toUser: ToUser.fromJson(petitionController.petition.user.toJson()),
            label: S.of(context).lClient,
            imageCompany: petitionController.petition.store.company.image,
          ),
          myRol: TypesRol.deliveryman,
        ),
      ),
    );
  }
}
