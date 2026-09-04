import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketBloc {
  static SocketBloc? _instance;
  final prefs = PreferencesProvider();

  SocketBloc._internal();

  factory SocketBloc() {
    _instance ??= SocketBloc._internal();
    return _instance!;
  }

  IO.Socket? socket;

  final streamController = StreamController<LatLng>.broadcast();

  Function(LatLng) get sink => streamController.sink.add;

  Stream<LatLng> get stream => streamController.stream;

  close() {
    if (socket == null) return;
    socket!.clearListeners();
    socket!.close();
    socket = null;
  }

  connect(int idUserDeliveryMen) {
    if (socket != null && socket!.connected) return;
    socket = IO.io(kSokect, <String, dynamic>{
      'path': '/socket.io/socket.io.js',
      'autoConnect': true,
      'transports': ['websocket'],
      'extraHeaders': {
        'auth': prefs.token,
        'iduserdeliverymen': idUserDeliveryMen
      }
    });
    socket!.connect();
    socket!.on('l', (data) {
      final LatLng position = LatLng(data[0], data[1]);
      sink(position);
    });
  }

  connected() {
    return socket?.connected;
  }

  disposeStreams() {
    streamController.close();
  }
}
