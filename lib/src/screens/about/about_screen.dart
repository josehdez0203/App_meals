import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/launch.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/widgets/primary_button.dart';
import 'package:app_meals/src/widgets/secondary_button.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).tAbout)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                children: [
                  const SizedBox(height: kDefaultPadding * 3),
                  GestureDetector(
                    onTap: () {
                      goToUrl('https://udemy.planck.biz/lili');
                    },
                    child: Image.asset("assets/screen/icon.png", height: 200),
                  ),
                  const SizedBox(height: kDefaultPadding * 3),
                  PrimaryButton(
                    icon: Icons.download,
                    color: Theme.of(context).colorScheme.secondary,
                    text: 'Source code',
                    onPressed: () =>
                        goToUrl('https://udemy.planck.biz/lili'),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  const Text(
                    "This software is distributed under MIT license. It is available at UDEMY in the author's account. Juan Pablo Guamán Rodríguez (Planck)",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kDefaultPadding),
                  SecondaryButton(
                    color: Theme.of(context).colorScheme.secondary,
                    text: 'Terms and Conditions',
                    onPressed: () =>
                        goToUrl('https://planck.biz/terminos-y-condiciones'),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  SecondaryButton(
                    color: Theme.of(context).colorScheme.secondary,
                    text: 'Privacy Policy',
                    onPressed: () =>
                        goToUrl('https://planck.biz/politica-de-privacidad'),
                  )
                ],
              ),
            ),
          )),
          PrimaryButton(
            color: Theme.of(context).colorScheme.secondary,
            text: 'Powered by Planck',
            onPressed: () => goToUrl('https://www.planck.biz/'),
          )
        ],
      ),
    );
  }
}
