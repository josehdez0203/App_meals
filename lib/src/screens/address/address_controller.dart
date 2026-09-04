import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/bloc/location_bloc.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/services/address_service.dart';

class AddressController extends ChangeNotifier {
  final AddressService addressService = AddressService();
  late AddressModel _address;
  Completer<GoogleMapController> _completer = Completer();
  late CameraPosition initialCameraPosition;

  Future<GoogleMapController> getController() async => await _completer.future;

  AddressController(AddressModel address) {
    _address = address;
    initialCameraPosition = CameraPosition(
        target: LatLng(_address.location.x, _address.location.y), zoom: 16);
  }

  AddressModel get address => _address;
  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  onMapCreated(GoogleMapController controller) async {
    _completer = Completer();
    _completer.complete(controller);
  }

  onCameraMove(CameraPosition cameraPosition) {
    _address.location.x = cameraPosition.target.latitude;
    _address.location.y = cameraPosition.target.longitude;
  }

  Future<AddressModel?> createAdrress() async {
    inAsyncCall = true;

    AddressModel? addressResponse;
    if (_address.id > 0) {
      addressResponse = await addressService.update(_address);
    } else {
      addressResponse = await addressService.create(_address);
    }

    if (addressResponse == null) {
      inAsyncCall = false;
      return null;
    }
    await DBProvider.db.createAddress(addressResponse);
    inAsyncCall = false;
    return addressResponse;
  }

  //When the client is not authenticated, it is only saved on a local basis.
  saveAdrressDb() async {
    inAsyncCall = true;
    _address.alias = S.current.lNewAddress;
    await DBProvider.db.createAddress(_address);
    inAsyncCall = false;
  }

  final LocationBloc _locationBloc = LocationBloc();

  myLocation() async {
    inAsyncCall = true;
    final List location = await _locationBloc.determinePosition();
    inAsyncCall = false;
    try {
      final GoogleMapController controller = await _completer.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(location[0], location[1]), zoom: 16)));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
