import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/bloc/location_bloc.dart';
import 'package:app_meals/src/common/file_helper.dart';
import 'package:app_meals/src/common/map_helper.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/models/company_model.dart';
import 'package:app_meals/src/models/taxi_model.dart';

class TaxiController extends ChangeNotifier {
  final CompanyModel company;

  final AddressModel _address = AddressModel(location: Location(x: 0, y: 0));

  late TaxiModel _taxi;
  Completer<GoogleMapController> _completer = Completer();
  late CameraPosition initialCameraPosition;

  Future<GoogleMapController> getController() async => await _completer.future;

  TaxiController(this.company) {
    _taxi = TaxiModel(
      from: AddressModel(location: Location(x: 0, y: 0)),
      to: AddressModel(
        location: Location(x: 0, y: 0),
        id: 1,
        alias: S.current.tPickupLocation,
      ),
    );

    initialCameraPosition = CameraPosition(
        target: LatLng(company.location.x, company.location.y), zoom: 16);
  }

  AddressModel get address => _address;

  bool _establishedPickupLocation = false;

  bool get establishedPickupLocation => _establishedPickupLocation;

  set establishedPickupLocation(bool establishedPickupLocation) {
    _establishedPickupLocation = establishedPickupLocation;
    notifyListeners();
  }

  bool _establishedDetinationLocation = false;

  bool get establishedDetinationLocation => _establishedDetinationLocation;

  set establishedDetinationLocation(bool establishedDetinationLocation) {
    _establishedDetinationLocation = establishedDetinationLocation;
    notifyListeners();
  }

  bool _initMove = false;

  bool get initMove => _initMove;

  set initMove(bool initMove) {
    _initMove = initMove;
    notifyListeners();
  }

  TaxiModel get taxi => _taxi;
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

  onCameraIdle() async {
    if (!_establishedPickupLocation) {
      _taxi.from.location.x = _address.location.x;
      _taxi.from.location.y = _address.location.y;
    } else if (!_establishedDetinationLocation) {
      _taxi.to.location.x = _address.location.x;
      _taxi.to.location.y = _address.location.y;
    }
    initMove = false;
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

  final Map<MarkerId, Marker> _markers = {};

  Set<Marker> get markers => _markers.values.toSet();

  final MarkerId markerIdPickupLocation =
      const MarkerId('markerIdPickupLocation');

  addMarkertPickupLocation(Location location) async {
    final icon = await toBytes('assets/exit.png', 290, isLocal: true);
    addMarker(markerIdPickupLocation, icon, LatLng(location.x, location.y));
  }

  final MarkerId markerIdDetinationLocation =
      const MarkerId('markerIdDetinationLocation');

  addMarkertDetinationLocation(Location location) async {
    final icon = await toBytes('assets/start.png', 200, isLocal: true);
    addMarker(markerIdDetinationLocation, icon, LatLng(location.x, location.y));
  }

  addMarker(MarkerId markerId, BitmapDescriptor icon, LatLng position) {
    final market = Marker(markerId: markerId, icon: icon, position: position);
    _markers[markerId] = market;
    notifyListeners();
  }

  centerMap() async {
    final GoogleMapController controller = await _completer.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        MapHelper().latLngBounds(_taxi.from.location.x, _taxi.from.location.y,
            _taxi.to.location.x, _taxi.to.location.y),
        130.0));
  }
}
