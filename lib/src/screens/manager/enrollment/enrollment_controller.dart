import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/bloc/location_bloc.dart';
import 'package:app_meals/src/models/category_model.dart';
import 'package:app_meals/src/models/enrollment_model.dart';
import 'package:app_meals/src/services/enrollment_service.dart';

class EnrollmentController extends ChangeNotifier {
  final EnrollmentService enrollmentService = EnrollmentService();
  final EnrollmentModel _enrollment =
      EnrollmentModel(location: Location(x: klatitudeMap, y: klongitudeMap));
  Completer<GoogleMapController> _completer = Completer();
  late CameraPosition initialCameraPosition;
  CategoryModel _category = CategoryModel(id: 0, name: '', image: '');

  EnrollmentController() {
    initialCameraPosition = const CameraPosition(
        target: LatLng(klatitudeMap, klongitudeMap), zoom: 16);
  }

  Completer<GoogleMapController> get completer => _completer;

  Future<GoogleMapController> getController() async => await _completer.future;

  CategoryModel get category => _category;

  set category(CategoryModel category) {
    _category = category;
    notifyListeners();
  }

  EnrollmentModel get enrollment => _enrollment;
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
    _enrollment.location.x = cameraPosition.target.latitude;
    _enrollment.location.y = cameraPosition.target.longitude;
  }

  Future<int> register() async {
    inAsyncCall = true;
    enrollment.marker = category.image;
    Map<String, dynamic>? decodedResp =
        await enrollmentService.enrollment(enrollment, category.id);
    inAsyncCall = false;

    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('company')) {
      enrollment.image = '';
      enrollment.name = '';
      enrollment.contact = '';
      enrollment.email = '';
      enrollment.address = '';
      // prefs.user = user;
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unknown;
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
