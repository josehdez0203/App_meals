import 'dart:async';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/screens/address/address_screen.dart';
import 'package:app_meals/src/screens/cart_summary/cart_summary_controller.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';
import 'package:app_meals/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:provider/provider.dart';

class AddressDropdown extends StatelessWidget {
  final bool isScreenMain;

  const AddressDropdown({super.key, required this.isScreenMain})
      ;
  final int milliseconds = 210;

  @override
  Widget build(BuildContext context) {
    final addressDropdownController =
        Provider.of<AddressDropdownController>(context);
    return isScreenMain
        ? _buttonTab1(context, addressDropdownController)
        : _buttonCartSumary(context, addressDropdownController);
  }

  TextButton _buttonTab1(BuildContext context,
      AddressDropdownController addressDropdownController) {
    goToAdrresScreen() {
      Timer(Duration(milliseconds: milliseconds), () {
        AddressModel address =
            AddressModel(location: Location(x: klatitudeMap, y: klongitudeMap));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddressScreen(address: address)));
      });
    }

    return TextButton(
      onPressed: () async {
        if (addressDropdownController.inAsyncCall) return;

        final tab1Controller =
            Provider.of<Tab1Controller>(context, listen: false);
        if (addressDropdownController.addressItems.length >= 2) {
          onTextFieldTap(context, addressDropdownController, goToAdrresScreen);
        } else {
          final navigator = Navigator.of(context);
          tab1Controller.inAsyncCall = true;
          AddressModel? address = await DBProvider.db.loadAddress();
          if (address == null) {
            address = AddressModel(
                location: Location(x: klatitudeMap, y: klongitudeMap));
            await DBProvider.db.createAddress(address);
          }
          tab1Controller.inAsyncCall = false;
          navigator.push(
            MaterialPageRoute(
              builder: (context) => AddressScreen(
                address: address!,
              ),
            ),
          );
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, color: Colors.white),
              const SizedBox(width: kDefaultPadding * .5),
              SizedBox(
                width: 115,
                child: Text(
                  addressDropdownController.dropdown.value == '0'
                      ? addressDropdownController.dropdown.name
                      : S
                          .of(context)
                          .tCloseTo(addressDropdownController.dropdown.name),
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: kDefaultPadding * .5),
              const Icon(Icons.arrow_downward_outlined, color: Colors.white),
              const SizedBox(width: kDefaultPadding * .5),
            ],
          ),
          Visibility(
            visible: addressDropdownController.inAsyncCall,
            child: const LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }

  GestureDetector _buttonCartSumary(BuildContext context,
      AddressDropdownController addressDropdownController) {
    goToAdrresScreen() {
      final cartSummaryController =
          Provider.of<CartSummaryController>(context, listen: false);

      Timer(Duration(milliseconds: milliseconds), () {
        if (cartSummaryController.isSumaryTaxi) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
          AddressModel address = AddressModel(
              location: Location(x: klatitudeMap, y: klongitudeMap));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddressScreen(address: address)));
        }
      });
    }

    return GestureDetector(
      onTap: () {
        if (addressDropdownController.inAsyncCall) return;
        onTextFieldTap(context, addressDropdownController, goToAdrresScreen);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.place_outlined, color: kPrimaryColor),
                const SizedBox(width: kDefaultPadding),
                Text(addressDropdownController.dropdown.name),
                Expanded(child: Container()),
                // const Icon(Icons.map_outlined, color: kPrimaryColor),
              ],
            ),
            Visibility(
              visible: addressDropdownController.inAsyncCall,
              child: const LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  onTextFieldTap(
      BuildContext context,
      AddressDropdownController addressDropdownController,
      Function goToAdrresScreen) {
    final cartSummaryController =
        Provider.of<CartSummaryController>(context, listen: false);
    final tab1Controller = Provider.of<Tab1Controller>(context, listen: false);
    DropDownState(
      DropDown(
        bottomSheetTitle: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.place_outlined, color: kPrimaryColor),
              const SizedBox(width: kDefaultPadding),
              Text(S.of(context).lDeliveryAddress,
                  style: const TextStyle(fontSize: 17))
            ],
          ),
        ),
        data: addressDropdownController.addressItems,
        selectedItems: (List<dynamic> selectedList) async {
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              if (item.value == '0') {
                goToAdrresScreen();
                return;
              } else {
                await addressDropdownController.setDropdown(item);
                if (!isScreenMain) {
                  cartSummaryController.load();
                }
                tab1Controller.load();
              }
              return;
            }
          }
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }
}
