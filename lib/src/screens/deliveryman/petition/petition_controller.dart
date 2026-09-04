import 'dart:async';

import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/common/file_helper.dart';
import 'package:app_meals/src/common/map_helper.dart';
import 'package:app_meals/src/models/petition_model.dart';
import 'package:app_meals/src/provider/push_provider.dart';
import 'package:app_meals/src/services/petition_service.dart';

class PetitionController extends ChangeNotifier {
  final _pushProvider = PushProvider();
  PetitionService petitionService = PetitionService();

  final Map<MarkerId, Marker> _markers = {};
  final MarkerId markerIdStore = const MarkerId('store');
  final MarkerId markerIdClient = const MarkerId('client');
  late PetitionModel _petition;

  Completer<GoogleMapController> _completer = Completer();

  late CameraPosition initialCameraPosition;

  PetitionController(PetitionModel petition) {
    // Clone the object, avoiding duplicate increases in the number of messages received.
    // PetitionsController _pushProvider AND PetitionController _pushProvider
    _petition = PetitionModel.fromJson(petition.toJson());

    initialCameraPosition = CameraPosition(
        target: LatLng(petition.location.x, petition.location.y), zoom: 16);
    addMarkers();

    _pushProvider.notifications.listen(evaluateNotification);
  }

  evaluateNotification(Map<String, dynamic> notification) async {
    if (petition.id.toString() == notification['orderId']) {
      switch (notification['type']) {
        case TypesNotification.changeOrderStatust:
          refreshPetition();
          break;
        case TypesNotification.messageChat:
          petition.notificationsDeliveryman++;
          notifyListeners();
          break;
        default:
      }
    }
  }

  refreshPetition() async {
    petition = await petitionService.findPetition(petition);
  }

  centerMap() async {
    final GoogleMapController controller = await _completer.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        MapHelper().latLngBounds(petition.location.x, petition.location.y,
            petition.start.x, petition.start.y),
        130.0));
  }

  cleanNotificationsClient() {
    _petition.notificationsDeliveryman = 0;
    notifyListeners();
  }

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  PetitionModel get petition => _petition;

  set petition(PetitionModel petition) {
    _petition = petition;
    notifyListeners();
  }

  addMarkers() async {
    await addMarkertStore();
    await addMarkertClient();
    notifyListeners();
  }

  Set<Marker> get markers => _markers.values.toSet();

  onMapCreated(GoogleMapController controller) async {
    _completer = Completer();
    _completer.complete(controller);
  }

  addMarkertStore() async {
    final icon = await toBytes('assets/restaurant.png', 170, isLocal: true);
    addMarker(markerIdStore, icon, LatLng(petition.start.x, petition.start.y));
  }

  addMarkertClient() async {
    final icon = await toBytes('assets/home.png', 150, isLocal: true);
    addMarker(
        markerIdClient, icon, LatLng(petition.location.x, petition.location.y));
  }

  addMarker(MarkerId markerId, BitmapDescriptor icon, LatLng position) {
    final market = Marker(markerId: markerId, icon: icon, position: position);
    _markers[markerId] = market;
  }

  collect() async {
    inAsyncCall = true;
    petition = await petitionService.collect(petition);
    inAsyncCall = false;
    notifyListeners();
  }

  cancel() async {
    inAsyncCall = true;
    petition = await petitionService.cancel(petition);
    inAsyncCall = false;
    notifyListeners();
  }

  deliver() async {
    inAsyncCall = true;
    await petitionService.deliver(petition);
    inAsyncCall = false;
    notifyListeners();
  }
}
