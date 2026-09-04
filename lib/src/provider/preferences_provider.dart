import 'package:flutter/foundation.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/user_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PreferencesProvider {
  static PreferencesProvider? _instance;

  PreferencesProvider._internal();

  factory PreferencesProvider() {
    _instance ??= PreferencesProvider._internal();
    return _instance!;
  }

  init() async {
    try {
      _instance!.preferences = await SharedPreferences.getInstance();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  SharedPreferences? preferences;

  set user(UserModel user) {
    if (preferences == null) return;
    preferences!.setInt('userId', user.id);
    preferences!.setString('email', user.email);
    preferences!.setString('image', user.image);
    preferences!.setString('fullName', user.fullName);
    preferences!.setString('phone', user.phone);
    preferences!.setStringList('roles', user.roles);
  }

  UserModel get user {
    return UserModel(
      id: preferences!.getInt('userId') ?? 0,
      email: preferences!.getString('email') ??
          'guest@${kNameApp.toLowerCase()}.com',
      fullName: preferences!.getString('fullName') ?? 'Guest $kNameApp',
      phone: preferences!.getString('phone') ?? 's/n',
      image: preferences!.getString('image') ?? kImageDeliveryManDefault,
      addresses: [],
      roles: preferences!.getStringList('roles') ?? [],
      token: preferences!.getString('token') ?? '',
    );
  }

  clean() {
    token = '';
    user = UserModel(
        id: 0,
        email: 'guest@${kNameApp.toLowerCase()}.com',
        fullName: 'Guest $kNameApp',
        phone: 's/n',
        image: kImageDeliveryManDefault,
        roles: [],
        token: '',
        addresses: []);
    DBProvider.db.deleteAddress();
    isOnline = false;
  }

  bool get isGuest {
    if (preferences == null) return true;
    if (preferences!.getInt('userId') == null) return true;
    return preferences!.getInt('userId')! <= 0;
  }

  bool get isAuth {
    if (preferences == null) return false;
    return preferences!.getInt('userId') != null &&
        preferences!.getInt('userId')! > 0;
  }

  String get token {
    if (preferences == null) return '';
    return preferences!.getString('token') ?? '';
  }

  set token(String? value) {
    if (preferences != null) preferences!.setString('token', value!);
  }

  String? get tokenPush {
    if (preferences == null) return null;
    return preferences!.getString('tokenPush');
  }

  set tokenPush(String? value) {
    if (preferences != null) preferences!.setString('tokenPush', value!);
  }

  bool get isOnline {
    if (preferences == null) return false;
    return preferences!.getBool('isOnline') ?? false;
  }

  set isOnline(bool value) {
    if (preferences != null) preferences!.setBool('isOnline', value);
  }

  String get idDevice {
    if (preferences!.getString('uuid') == null) {
      preferences!.setString('uuid', const Uuid().v4());
    }
    // ignore: recursive_getters
    return preferences!.getString('uuid') ?? idDevice;
  }

  set idDevice(String value) {
    if (preferences != null) preferences!.setString('uuid', value);
  }

  String get locale {
    if (preferences == null) return 'es';
    return preferences!.getString('locale') ?? 'es';
  }

  set locale(String? value) {
    if (preferences != null) preferences!.setString('locale', value!);
  }
}
