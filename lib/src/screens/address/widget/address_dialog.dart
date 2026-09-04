import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/screens/address/address_controller.dart';
import 'package:app_meals/src/screens/address/widget/address_input.dart';
import 'package:app_meals/src/screens/address/widget/alias_input.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';
import 'package:app_meals/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:provider/provider.dart';

class AddressDialog extends StatelessWidget {
  AddressDialog(this.addressController, {super.key}) ;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AddressController addressController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(kDefaultPadding * 1.6),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AliasInput(addressController: addressController),
            const SizedBox(height: kDefaultPadding),
            AddressInput(addressController: addressController)
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.reply_outlined),
              const SizedBox(width: kDefaultPadding * .5),
              Text(S.of(context).bCancel),
              const SizedBox(width: kDefaultPadding * .5),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            _formKey.currentState!.save();
            if (!_formKey.currentState!.validate()) return;
            final navigator = Navigator.of(context);
            final tab1Controller =
                Provider.of<Tab1Controller>(context, listen: false);
            final addressDropdownController =
                Provider.of<AddressDropdownController>(context, listen: false);
            navigator.pop();
            AddressModel? address = await addressController.createAdrress();
            if (address == null) return;
            await addressDropdownController.loadAddress();
            await addressDropdownController.setDropdownByAddess(address);
            tab1Controller.load();
            navigator.popUntil((route) => route.isFirst);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save_outlined),
              const SizedBox(width: kDefaultPadding * .5),
              Text(S.of(context).bSaveChanges),
              const SizedBox(width: kDefaultPadding * .5),
            ],
          ),
        )
      ],
    );
  }
}
