import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/address/address_screen.dart';
import 'package:app_meals/src/screens/addresses/addresses_controller.dart';
import 'package:app_meals/src/screens/addresses/widget/address_dismissible.dart';
import 'package:app_meals/src/widgets/secondary_button.dart';
import 'package:provider/provider.dart';

class AddressesScreen extends StatelessWidget {
  AddressesScreen({super.key});

  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).tAddresses)),
      body: ChangeNotifierProvider<AddressesController>.value(
        value: AddressesController(),
        child: Consumer<AddressesController>(
          builder: (context, addressesController, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                  visible: addressesController.inAsyncCall,
                  child: const LinearProgressIndicator()),
              Expanded(
                  child: ListView.builder(
                itemCount: addressesController.addresses.length,
                itemBuilder: (context, index) => AddressDismissible(
                    addressesController,
                    address: addressesController.addresses[index]),
              )),
              SecondaryButton(
                color: Theme.of(context).colorScheme.secondary,
                text: S.of(context).lNewAddress,
                onPressed: () {
                  AddressModel address = AddressModel(
                      location: Location(x: klatitudeMap, y: klongitudeMap));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddressScreen(address: address)));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
