import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/bloc/socket_bloc.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

class LocationBloc {
  static LocationBloc? _instance;

  LocationBloc._internal();

  factory LocationBloc() {
    _instance ??= LocationBloc._internal();
    return _instance!;
  }

  final SocketBloc _socketBloc = SocketBloc();
  StreamSubscription? _getPositionSubscription;
  final _pref = PreferencesProvider();

  Future<bool> start() async {
    _socketBloc.connect(0);
    LocationPermission permission;
    bool serviceEnabled;
    try {
      await determinePosition();

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    } catch (e) {
      _socketBloc.close();
      _getPositionSubscription?.cancel();
      if (kDebugMode) {
        print(e);
      }
      return false;
    }

    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 50);

    int instant = DateTime.now().millisecondsSinceEpoch;

    _getPositionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if ((instant + 5100) > DateTime.now().millisecondsSinceEpoch) return;
      instant = DateTime.now().millisecondsSinceEpoch;
      if (position == null) return;
      _socketBloc.socket?.emit('l', {
        "id": _pref.user.id,
        "p": LatLng(position.latitude, position.longitude)
      });
    });
    return true;
  }

  stop() {
    _socketBloc.close();
    _getPositionSubscription?.cancel();
  }

  Future<List> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Position? position = await Geolocator.getLastKnownPosition();
        if (position == null) return [klatitudeMap, klongitudeMap];
        return [position.latitude, position.longitude];
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return [klatitudeMap, klongitudeMap];
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return [klatitudeMap, klongitudeMap];
      }

      return await Geolocator.getCurrentPosition(
              timeLimit: const Duration(seconds: 45))
          .then((value) => [value.latitude, value.longitude])
          .onError((error, stackTrace) => [klatitudeMap, klongitudeMap])
          .catchError((error) => [klatitudeMap, klongitudeMap]);
    } catch (e) {
      return [klatitudeMap, klongitudeMap];
    }
  }
}
