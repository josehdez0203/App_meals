import 'package:flutter/material.dart';
import 'package:app_meals/src/models/hour_model.dart';
import 'package:app_meals/src/models/store_company_model.dart';
import 'package:app_meals/src/services/store_manager_service.dart';

class HoursController extends ChangeNotifier {
  final StoreManagerService _storeManagerService = StoreManagerService();

  final StoreCompanyModel storeCompany;

  List<HourModel> _hours = [];

  List<HourModel> get hours => _hours;

  HoursController(this.storeCompany) {
    load();
  }

  bool _inAsyncCall = false;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  load() async {
    inAsyncCall = true;
    _hours = await _storeManagerService.getHours(storeCompany.id);
    inAsyncCall = false;
  }

  updateHour(HourModel hour) async {
    inAsyncCall = true;
    hour = await _storeManagerService.updateHour(hour);
    inAsyncCall = false;
    final index = hours.indexWhere((h) => h.id == hour.id);
    if (index > 0) hours[index] = hour;
    notifyListeners();
  }
}
