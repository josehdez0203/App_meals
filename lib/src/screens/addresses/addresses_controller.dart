import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/services/address_service.dart';

class AddressesController extends ChangeNotifier {
  final AddressService addressService = AddressService();

  List<AddressModel> _addresses = [];

  List<AddressModel> get addresses => _addresses;

  AddressesController() {
    load();
  }

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  load() async {
    inAsyncCall = true;
    _addresses = await addressService.getAdress();
    inAsyncCall = false;
  }

  Future<bool> remove(AddressModel address) async {
    addresses.remove(address);
    return await addressService.remove(address);
  }
}
