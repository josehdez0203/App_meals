import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/user_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlLogin = 'auth/login';
const _urlCheck = 'auth/check';
const _urlRegister = 'auth/register';
const _urlUpdate = 'auth/update';
const _urlUpdatePasswor = 'auth/update-passwor';
const _urlGoogle = 'auth/google';
const _urlRecover = 'auth/recover';
const _urlLogOut = 'auth/log-out';
const _urlUpdateTokenPush = 'auth/update-token-push';

class AuthService {
  final prefs = PreferencesProvider();

  Future<bool> updatePasswor(String password) async {
    var client = http.Client();
    try {
      final resp = await client.patch(Uri.parse('$kDomain$_urlUpdatePasswor'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${prefs.token}',
          },
          body: jsonEncode({
            "password": password,
          }));
      if (resp.statusCode == 200) return true;
    } catch (err) {
      if (kDebugMode) {
        print('AuthService password: $err');
      }
    } finally {
      client.close();
    }
    return false;
  }

  Future<Map<String, dynamic>?> changeImage(String image) async {
    var client = http.Client();
    try {
      final resp = await client.patch(Uri.parse('$kDomain$_urlUpdate'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${prefs.token}',
          },
          body: jsonEncode({
            "image": image,
          }));
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return decodedResp;
    } catch (err) {
      if (kDebugMode) {
        print('AuthService update: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<Map<String, dynamic>?> update(
      String email, String fullName, String phone) async {
    var client = http.Client();
    try {
      final resp = await client.patch(Uri.parse('$kDomain$_urlUpdate'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${prefs.token}',
          },
          body: jsonEncode({
            "email": email,
            "fullName": fullName,
            "phone": phone,
          }));
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return decodedResp;
    } catch (err) {
      if (kDebugMode) {
        print('AuthService update: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<bool> logOut() async {
    var client = http.Client();
    try {
      final resp = await client.delete(
        Uri.parse('$kDomain$_urlLogOut/${prefs.idDevice}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode == 200) return true;
    } catch (err) {
      if (kDebugMode) {
        print('AuthService logOut: $err');
      }
    } finally {
      client.close();
    }
    return false;
  }

  Future<Map<String, dynamic>?> recover(String email) async {
    var client = http.Client();
    try {
      final resp = await client.patch(
        Uri.parse('$kDomain$_urlRecover/$email'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      return json.decode(resp.body);
    } catch (err) {
      if (kDebugMode) {
        print('AuthService recover: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<Map<String, dynamic>?> check() async {
    var client = http.Client();
    try {
      final resp = await client
          .patch(Uri.parse('$kDomain$_urlCheck/${prefs.idDevice}'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${prefs.token}',
      });
      return json.decode(resp.body);
    } catch (err) {
      if (kDebugMode) {
        print('AuthService check: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<UserModel?> login(String email, String password) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse('$kDomain$_urlLogin'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "email": email,
            "password": password,
            "idDevice": prefs.idDevice,
            "tokenPush": prefs.tokenPush,
          }));
      if (resp.statusCode != 201) return null;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      UserModel user = UserModel.fromJson(decodedResp);
      return user;
    } catch (err) {
      if (kDebugMode) {
        print('AuthService login: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<Map<String, dynamic>?> google(
      String idGoogle, String fullName, String email, String image) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse('$kDomain$_urlGoogle'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "image": image,
            "email": email,
            "fullName": fullName,
            "idDevice": prefs.idDevice,
            "tokenPush": prefs.tokenPush,
            "idGoogle": idGoogle,
          }));
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return decodedResp;
    } catch (err) {
      if (kDebugMode) {
        print('AuthService google: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<Map<String, dynamic>?> register(
      String email, String password, String fullName, String phone) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse('$kDomain$_urlRegister'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "email": email,
            "password": password,
            "fullName": fullName,
            "phone": phone,
            "idDevice": prefs.idDevice,
            "tokenPush": prefs.tokenPush,
          }));
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return decodedResp;
    } catch (err) {
      if (kDebugMode) {
        print('AuthService register: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<bool> updateTokenPush(String tokenPush) async {
    var client = http.Client();
    try {
      final resp = await client.patch(
        Uri.parse('$kDomain$_urlUpdateTokenPush'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "idDevice": prefs.idDevice,
          "tokenPush": tokenPush,
        }),
      );
      if (resp.statusCode == 201) return true;
    } catch (err) {
      if (kDebugMode) {
        print('AuthService updateTokenPush: $err');
      }
    } finally {
      client.close();
    }
    return false;
  }
}
