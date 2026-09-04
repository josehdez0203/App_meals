import 'dart:async';

import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/common/file_helper.dart';
import 'package:app_meals/src/common/map_helper.dart';
import 'package:app_meals/src/models/request_model.dart';
import 'package:app_meals/src/provider/push_provider.dart';
import 'package:app_meals/src/services/request_service.dart';

class RequestController extends ChangeNotifier {
  final _pushProvider = PushProvider();
  RequestService requestService = RequestService();

  final Map<MarkerId, Marker> _markers = {};
  final MarkerId markerIdStore = const MarkerId('store');
  final MarkerId markerIdClient = const MarkerId('client');
  late RequestModel _request;

  Completer<GoogleMapController> _completer = Completer();

  late CameraPosition initialCameraPosition;

  RequestController(RequestModel request) {
    // Clone the object, avoiding duplicate increases in the number of messages received.
    // RequestsController _pushProvider AND RequestController _pushProvider
    _request = RequestModel.fromJson(request.toJson());

    initialCameraPosition = CameraPosition(
        target: LatLng(request.location.x, request.location.y), zoom: 16);
    addMarkers();

    _pushProvider.notifications.listen(evaluateNotification);
  }

  evaluateNotification(Map<String, dynamic> notification) async {
    if (request.id.toString() == notification['orderId']) {
      switch (notification['type']) {
        case TypesNotification.changeOrderStatust:
          refreshRequest();
          break;
        case TypesNotification.messageChat:
          request.notificationsDeliveryman++;
          notifyListeners();
          break;
        default:
      }
    }
  }

  refreshRequest() async {
    request = await requestService.findRequest(request);
  }

  centerMap() async {
    final GoogleMapController controller = await _completer.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        MapHelper().latLngBounds(request.location.x, request.location.y,
            request.store.location.x, request.store.location.y),
        130.0));
  }

  cleanNotificationsClient() {
    _request.notificationsDeliveryman = 0;
    notifyListeners();
  }

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  RequestModel get request => _request;

  set request(RequestModel request) {
    _request = request;
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
    addMarker(markerIdStore, icon,
        LatLng(request.store.location.x, request.store.location.y));
  }

  addMarkertClient() async {
    final icon = await toBytes('assets/home.png', 150, isLocal: true);
    addMarker(
        markerIdClient, icon, LatLng(request.location.x, request.location.y));
  }

  addMarker(MarkerId markerId, BitmapDescriptor icon, LatLng position) {
    final market = Marker(markerId: markerId, icon: icon, position: position);
    _markers[markerId] = market;
  }
}
