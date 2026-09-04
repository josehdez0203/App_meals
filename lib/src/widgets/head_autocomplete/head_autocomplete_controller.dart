import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/models/prediction_model.dart';
import 'package:app_meals/src/services/address_service.dart';

class HeadAutocompleteController extends ChangeNotifier {
  final AddressService addressService = AddressService();

  List<PredictionModel> predictions = [];

  final Function getController;
  final double latitude;
  final double longitude;

  HeadAutocompleteController({
    required this.getController,
    required this.latitude,
    required this.longitude,
  });

  autocomplete(String place) async {
    if (place.length < 3) {
      predictions.clear();
      notifyListeners();
      return;
    }
    predictions =
        await addressService.autocomplete(place, lt: latitude, lg: longitude);
    notifyListeners();
  }

  geocode(String placeId) async {
    Location? location = await addressService.geocode(placeId);
    if (location == null) return;
    try {
      (await getController()).animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(location.x, location.y), zoom: 16)));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
