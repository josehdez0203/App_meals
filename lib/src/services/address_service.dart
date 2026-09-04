import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/models/prediction_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlAddresses = 'client/address';
const _urlCreate = 'client/address';
const _urlUpdate = 'client/address';
const _urlRemove = 'client/address';

const _urlAutocomplete = 'client/address/autocomplete';
const _urlGeocode = 'client/address/geocode';

class AddressService {
  final prefs = PreferencesProvider();

  Future<bool> remove(AddressModel address) async {
    var client = http.Client();
    try {
      final resp = await client.delete(
        Uri.parse('$kDomain$_urlRemove/${address.id}'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode == 200) return true;
    } catch (err) {
      if (kDebugMode) {
        print('AddressService geocode: $err');
      }
    } finally {
      client.close();
    }
    return false;
  }

  Future<Location?> geocode(String placeId) async {
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlGeocode/$placeId'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return null;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['locations']) {
        return Location.fromJson(item);
      }
    } catch (err) {
      if (kDebugMode) {
        print('AddressService geocode: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<List<PredictionModel>> autocomplete(String place,
      {required double lt, required double lg}) async {
    List<PredictionModel> predictions = [];

    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse(
            '$kDomain$_urlAutocomplete/$place?longitude=$lg&latitude=$lt'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return predictions;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['predictions']) {
        predictions.add(PredictionModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('AddressService autocomplete: $err');
      }
    } finally {
      client.close();
    }
    return predictions;
  }

  Future<List<AddressModel>> getAdress() async {
    List<AddressModel> addresses = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlAddresses'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return addresses;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['addresses']) {
        addresses.add(AddressModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('AddressService getAdress: $err');
      }
    } finally {
      client.close();
    }
    return addresses;
  }

  Future<AddressModel?> create(AddressModel address) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse('$kDomain$_urlCreate'),
          headers: {
            'Authorization': 'Bearer ${prefs.token}',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: address.toHttpBody());

      if (resp.statusCode != 201) return null;

      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return AddressModel.fromJson(decodedResp['address']);
    } catch (err) {
      if (kDebugMode) {
        print('AddressService create: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<AddressModel?> update(AddressModel address) async {
    var client = http.Client();
    try {
      final resp =
          await client.patch(Uri.parse('$kDomain$_urlUpdate/${address.id}'),
              headers: {
                'Authorization': 'Bearer ${prefs.token}',
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: address.toHttpBody());

      if (resp.statusCode != 200) return null;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return AddressModel.fromJson(decodedResp['address']);
    } catch (err) {
      if (kDebugMode) {
        print('AddressService create: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }
}
