import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/screens/address/address_screen.dart';
import 'package:app_meals/src/screens/addresses/addresses_controller.dart';
import 'package:app_meals/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:provider/provider.dart';

class AddressDismissible extends StatelessWidget {
  const AddressDismissible(
    this.addressesController, {
    required this.address,
    super.key,
  }) ;

  final AddressesController addressesController;
  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Dismissible(
        background: Container(color: Colors.red),
        key: Key(address.id.toString()),
        confirmDismiss: (direction) async {
          if (addressesController.addresses.length > 1) return true;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: kErrorColor,
            content: Text(S.of(context).errDeleteAllAddress),
          ));
          return null;
        },
        onDismissed: (_) async {
          if (addressesController.addresses.length <= 1) return;
          final addressDropdownController =
              Provider.of<AddressDropdownController>(context, listen: false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(S.of(context).mRAddressRemoved),
          ));
          DBProvider.db.deleteAddressByID(address.id);
          await addressesController.remove(address);
          addressDropdownController
              .setDropdownByAddess(addressesController.addresses[0]);
          addressDropdownController.loadAddress();
        },
        child: Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddressScreen(address: address),
                  ),
                );
              },
              trailing: const Icon(Icons.pinch_outlined, color: kPrimaryColor),
              leading: const Icon(Icons.public_outlined, color: kPrimaryColor),
              title: Text(address.alias),
              subtitle: Text(address.address),
            ),
            const Divider(color: kPrimaryColor, thickness: 1)
          ],
        ),
      ),
    );
  }
}
