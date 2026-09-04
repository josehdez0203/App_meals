import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/src/bloc/location_bloc.dart';
import 'package:app_meals/src/models/petition_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/provider/push_provider.dart';
import 'package:app_meals/src/services/auth_service.dart';
import 'package:app_meals/src/services/petition_service.dart';

class PetitionsController with ChangeNotifier {
  final AuthService authService = AuthService();
  final PetitionService petitionService = PetitionService();

  final _pushProvider = PushProvider();
  final _pref = PreferencesProvider();

  final LocationBloc _locationBloc = LocationBloc();

  late bool _isOnline;
  int _currentScreen = 0;
  DateTime _selectedDay = DateTime.now();

  int get currentScreen => _currentScreen;

  set currentScreen(int current) {
    _currentScreen = current;
    notifyListeners();
  }

  DateTime get selectedDay => _selectedDay;

  set selectedDay(DateTime selectedDay) {
    _selectedDay = selectedDay;
    _petitions.clear();
    loadPetitions();
    notifyListeners();
  }

  PetitionsController() {
    loadPetitions();

    _isOnline = _pref.isOnline;
    if (_isOnline) {
      startOnline();
    } else {
      startOffline();
    }

    _pushProvider.notifications.listen(evaluateNotification);
  }

  evaluateNotification(Map<String, dynamic> notification) async {
    switch (notification['type']) {
      case TypesNotification.newOrder:
        final int newOrderId = int.parse(notification['orderId'].toString());
        final indexOrder =
            _petitions.indexWhere((petition) => petition.id == newOrderId);
        if (indexOrder < 0) {
          _petitions = await petitionService.findNearPetitions();
          notifyListeners();
        }
        break;
      case TypesNotification.messageChat:
        final orderId = int.parse(notification['orderId']);
        final index = _petitions.indexWhere((or) => or.id == orderId);
        if (index < 0) return;
        _petitions[index].notificationsDeliveryman++;
        notifyListeners();
        break;
      default:
    }
  }

  cleanNotificationsDeliveryman(int orderId) {
    final index = _petitions.indexWhere((or) => or.id == orderId);
    if (index < 0) return;
    _petitions[index].notificationsDeliveryman = 0;
    notifyListeners();
  }

  bool get isOnline => _isOnline;

  set isOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  startOnline() async {
    inAsyncCall = true;

    bool isOk = await _locationBloc.start();
    if (!isOk) {
      inAsyncCall = false;
      isOnline = false;
      _pref.isOnline = isOnline;
      return;
    }

    List position = await _locationBloc.determinePosition();
    final response =
        await petitionService.activate(true, position[0], position[1]);
    inAsyncCall = false;
    isOnline = response;
    _pref.isOnline = isOnline;
  }

  startOffline() async {
    inAsyncCall = true;
    List position = await _locationBloc.determinePosition();
    final response =
        await petitionService.activate(false, position[0], position[1]);
    inAsyncCall = false;
    isOnline = !response;
    _pref.isOnline = isOnline;
    _locationBloc.stop();
  }

  loadPetitions() async {
    inAsyncCall = true;
    if (currentScreen == 0) {
      _petitions = await petitionService.findNearPetitions();
    } else {
      String orderedAt = selectedDay.toString().split(' ')[0];
      _petitions = await petitionService.history(orderedAt);
    }
    inAsyncCall = false;
    notifyListeners();
  }

  List<PetitionModel> _petitions = [];

  get petitions => _petitions;

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  Future<List> apply(PetitionModel petition) async {
    inAsyncCall = true;
    Map<String, dynamic>? decodedResp = await petitionService.apply(petition);

    inAsyncCall = false;
    if (decodedResp == null) {
      return [CodeError.unknown];
    }
    if (decodedResp.containsKey('petition')) {
      return [CodeError.none, PetitionModel.fromJson(decodedResp['petition'])];
    } else if (decodedResp.containsKey('codeError')) {
      return [decodedResp['codeError']];
    }
    return [CodeError.unknown];
  }

  Future<int> checkSession() async {
    Map<String, dynamic>? decodedResp = await authService.check();
    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('user')) {
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unauthorized;
  }

  removeOrder(PetitionModel petition) {
    final index = _petitions.indexWhere((pr) => pr.id == petition.id);
    if (index < 0) return;
    _petitions.removeAt(index);
    notifyListeners();
  }
}
