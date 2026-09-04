import 'dart:async';

import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/status_constant.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/bloc/socket_bloc.dart';
import 'package:app_meals/src/common/file_helper.dart';
import 'package:app_meals/src/common/map_helper.dart';
import 'package:app_meals/src/models/order_model.dart';
import 'package:app_meals/src/provider/push_provider.dart';
import 'package:app_meals/src/services/market_service.dart';

class OrderController extends ChangeNotifier {
  final _pushProvider = PushProvider();
  final MarketService marketService = MarketService();

  final Map<MarkerId, Marker> _markers = {};
  final MarkerId markerIdStore = const MarkerId('store');
  final MarkerId markerIdClient = const MarkerId('client');
  final MarkerId markerIdDeliveryMan = const MarkerId('deliveryman');
  late BitmapDescriptor iconDeliveryMan;
  late OrderModel _order;
  final SocketBloc _socketBloc = SocketBloc();

  Completer<GoogleMapController> _completer = Completer();
  late CameraPosition initialCameraPosition;

  OrderController(OrderModel order) {
    initialCameraPosition = CameraPosition(
        target: LatLng(order.location.x, order.location.y), zoom: 16);

    // Clone the object, avoiding duplicate increases in the number of messages received.
    // Tab2Controller _pushProvider AND OrderController _pushProvider
    _order = OrderModel.fromJson(order.toJson());

    addMarkers();
    onListenerPositions();

    _pushProvider.notifications.listen(evaluateNotification);
  }

  evaluateNotification(Map<String, dynamic> notification) async {
    if (order.id.toString() == notification['orderId']) {
      switch (notification['type']) {
        case TypesNotification.changeOrderStatust:
          refreshOrder();
          break;
        case TypesNotification.messageChat:
          order.notificationsClient++;
          notifyListeners();
          break;
        default:
      }
    }
  }

  qualify() async {
    await marketService.qualify(order);
  }

  refreshOrder() async {
    order = await marketService.getOrder(order);
    onListenerPositions();
  }

  cleanNotificationsClient() {
    order.notificationsClient = 0;
    notifyListeners();
  }

  OrderModel get order => _order;

  set order(OrderModel order) {
    _order = order;
    notifyListeners();
  }

  centerMap() async {
    final GoogleMapController controller = await _completer.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        MapHelper().latLngBounds(
            order.location.x, order.location.y, order.start.x, order.start.y),
        130.0));
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

  onListenerPositions() async {
    _socketBloc.close();
    if (order.status == StatusOrder.assigned ||
        order.status == StatusOrder.taken) {
      addMarkertDeliveryMan(0, 0);
      _socketBloc.connect(order.deliveryman!.id);
      _socketBloc.stream.listen((position) {
        updateLocationDeliveryMan(position);
      });
    }
  }

  addMarkertStore() async {
    final String urtlImage = order.store.company.marker.length <= 5
        ? kImageCategoryAll
        : order.store.company.marker;
    final icon = await toBytes(urtlImage, 130, isLocal: false);
    addMarker(markerIdStore, icon, LatLng(order.start.x, order.start.y));
  }

  addMarkertClient() async {
    final icon = await toBytes('assets/home.png', 160, isLocal: true);
    addMarker(markerIdClient, icon, LatLng(order.location.x, order.location.y));
  }

  addMarkertDeliveryMan(double lt, double lg) async {
    final icon = await toBytes('assets/car.png', 110, isLocal: true);
    iconDeliveryMan = icon;
    addMarker(markerIdDeliveryMan, icon, LatLng(lt, lg));
  }

  addMarker(MarkerId markerId, BitmapDescriptor icon, LatLng position) {
    final market = Marker(markerId: markerId, icon: icon, position: position);
    _markers[markerId] = market;
  }

  updateLocationDeliveryMan(LatLng position) async {
    LatLng oldPosition = _markers[markerIdDeliveryMan]!.position;

    double rotation = Geolocator.bearingBetween(oldPosition.latitude,
        oldPosition.longitude, position.latitude, position.longitude);

    final market = Marker(
      markerId: markerIdDeliveryMan,
      icon: iconDeliveryMan,
      position: position,
      rotation: rotation,
    );
    _markers[markerIdDeliveryMan] = market;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _socketBloc.disposeStreams();
  }
}
