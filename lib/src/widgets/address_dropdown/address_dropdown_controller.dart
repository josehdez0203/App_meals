import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/services/address_service.dart';

class AddressDropdownController extends ChangeNotifier {
  final AddressService addressService = AddressService();
  final List<AddressModel> _addresses = [];

  SelectedListItem _dropdown =
      SelectedListItem(name: S.current.lNewAddress, value: '0');
  bool _inAsyncCall = false;
  final List<SelectedListItem> _addressItems = [];

  AddressDropdownController() {
    initAddress();
    loadAddress();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  SelectedListItem get dropdown => _dropdown;

  // When an address is created, we change the view using an address
  Future<bool> setDropdownByAddess(AddressModel address) async {
    _dropdown =
        SelectedListItem(name: address.alias, value: address.id.toString());
    await DBProvider.db.createAddress(address);
    notifyListeners();
    return true;
  }

  Future<bool> setDropdown(SelectedListItem dropdown) async {
    _dropdown = dropdown;
    AddressModel address =
        _addresses.firstWhere((adr) => adr.id.toString() == dropdown.value);
    await DBProvider.db.createAddress(address);
    notifyListeners();
    return true;
  }

  List<SelectedListItem> get addressItems => _addressItems;

  setAddressItems(List<AddressModel> addresses) {
    _addressItems.clear();
    for (var address in addresses) {
      _addressItems.add(
        SelectedListItem(name: address.alias, value: address.id.toString()),
      );
    }
    notifyListeners();
  }

  initAddress() async {
    AddressModel? address = await DBProvider.db.loadAddress();
    if (address != null) {
      _dropdown =
          SelectedListItem(name: address.alias, value: address.id.toString());
      notifyListeners();
    }
  }

  loadAddress() async {
    inAsyncCall = true;
    final addresses = await addressService.getAdress();
    _addresses.clear();
    addresses.add(AddressModel(
        alias: S.current.lNewAddress,
        location: Location(x: klatitudeMap, y: klongitudeMap)));
    _addresses.addAll(addresses);
    setAddressItems(addresses);
    inAsyncCall = false;
    notifyListeners();
  }
}
