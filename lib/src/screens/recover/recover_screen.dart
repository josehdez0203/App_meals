import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/recover/recover_controller.dart';
import 'package:app_meals/src/screens/recover/widget/email_input.dart';
import 'package:app_meals/src/screens/recover/widget/recover_button.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class RecoverScreen extends StatelessWidget {
  RecoverScreen({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).bRecoverAccount)),
      body: ChangeNotifierProvider<RecoverController>.value(
        value: RecoverController(),
        child: Consumer<RecoverController>(
          builder: (context, recoverController, child) => ModalProgressHUD(
            inAsyncCall: recoverController.inAsyncCall,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: formKey,
                  child: Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.asset('assets/screen/recover.png', width: 380),
                          const SizedBox(height: kDefaultPadding),
                          EmailInput(recoverController),
                          const SizedBox(height: kDefaultPadding * 2),
                        ],
                      ),
                    ),
                  )),
                ),
                RecoverButton(recoverController, formKey: formKey)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
