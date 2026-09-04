import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/bloc/location_bloc.dart';
import 'package:app_meals/src/common/file_helper.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/profile/profile_controller.dart';
import 'package:app_meals/src/screens/profile/widget/amount_input.dart';
import 'package:app_meals/src/screens/profile/widget/balance_input.dart';
import 'package:app_meals/src/screens/profile/widget/change_password_button.dart';
import 'package:app_meals/src/screens/profile/widget/email_input.dart';
import 'package:app_meals/src/screens/profile/widget/name_input.dart';
import 'package:app_meals/src/screens/profile/widget/phone_input.dart';
import 'package:app_meals/src/screens/profile/widget/save_button.dart';
import 'package:app_meals/src/screens/welcome/welcome_screen.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/confirmation_dialog.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:app_meals/src/widgets/money_input.dart';
import 'package:app_meals/src/widgets/upload_file/upload_file.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileController>.value(
      value: ProfileController(),
      child: Consumer<ProfileController>(
        builder: (context, profileController, child) => Scaffold(
          appBar: AppBar(
            title: Text(pref.user.fullName),
            actions: [
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        S.of(context).mDLogoutSession,
                        labelOk: S.of(context).bAccept,
                        iconOk: const Icon(Icons.output_outlined),
                        onPressedOk: () {
                          _logOut(context, profileController);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.output_outlined, size: 30))
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: profileController.inAsyncCall,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: formKey,
                  child: Expanded(
                      child: Container(
                    padding: const EdgeInsets.only(
                        left: kDefaultPadding, right: kDefaultPadding),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: kDefaultPadding * 1.3),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => UploadFile((image) async {
                                  profileController.inAsyncCall = true;
                                  String imageUpload = await uploadFile(
                                      image,
                                      'user/${pref.user.id}',
                                      '${pref.user.id}-${DateTime.now().toIso8601String()}',
                                      kTargetWidthUser);
                                  profileController.changeImage(imageUpload);
                                }),
                              );
                            },
                            child: CircularPercentIndicator(
                              radius: 50.0,
                              lineWidth: 3.0,
                              percent: 1.0,
                              center: AvatarImage(
                                  width: 80,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  image: pref.user.image),
                              progressColor: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: kDefaultPadding * 1.3),
                          if (pref.user.roles.contains(TypesRol.deliveryman))
                            _contentDeliveryMan(profileController),
                          if (!pref.user.roles.contains(TypesRol.deliveryman))
                            _contentIsNotDeliveryMan(profileController),
                          const SizedBox(height: kDefaultPadding * 5),
                        ],
                      ),
                    ),
                  )),
                ),
                ProfileButton(profileController, formKey: formKey)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contentDeliveryMan(ProfileController profileController) {
    return Column(
      children: [
        BalanceInput(profileController.balance.balance),
        const SizedBox(height: kDefaultPadding * 1.3),
        AmountInput(profileController.balance.amount),
        const SizedBox(height: kDefaultPadding * 1.3),
        PhoneInput(profileController),
        const SizedBox(height: kDefaultPadding * 1.3),
        EmailInput(profileController),
        const SizedBox(height: kDefaultPadding * 2.6),
        ChangePasswordButton(profileController),
      ],
    );
  }

  Widget _contentIsNotDeliveryMan(ProfileController profileController) {
    return Column(
      children: [
        MoneyInput(profileController.balance.money),
        const SizedBox(height: kDefaultPadding * 1.3),
        NameInput(profileController),
        const SizedBox(height: kDefaultPadding * 1.3),
        PhoneInput(profileController),
        const SizedBox(height: kDefaultPadding * 1.3),
        EmailInput(profileController),
        const SizedBox(height: kDefaultPadding * 2.6),
        ChangePasswordButton(profileController),
      ],
    );
  }

  _logOut(BuildContext context, ProfileController profileController) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    bool islogOut = await profileController.logOut();

    if (!islogOut && !pref.isGuest) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(s.errUnknown),
      ));
      return;
    }

    if (pref.user.roles.contains(TypesRol.deliveryman)) {
      LocationBloc().stop();
    }

    pref.clean();
    navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (Route<dynamic> route) {
      return false;
    });
  }
}
