import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/petition_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlNearPetition = 'deliveryman/petition/near/';
const _urlOrderAtPetition = 'deliveryman/petition/ordered-at/';
const _urlIdPetition = 'deliveryman/petition/id/';

const _urlCollect = 'deliveryman/petition/collect/';
const _urlDeliver = 'deliveryman/petition/deliver/';
const _urlCancel = 'deliveryman/petition/cancel/';
const _urlApply = 'deliveryman/petition/apply/';
const _urlActivate = 'deliveryman/petition/activate/';

class PetitionService {
  final prefs = PreferencesProvider();

  Future<PetitionModel> findPetition(PetitionModel petition) async {
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlIdPetition${petition.id}'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return petition;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return PetitionModel.fromJson(decodedResp['petition']);
    } catch (err) {
      if (kDebugMode) {
        print('PetitionService petitions: $err');
      }
    } finally {
      client.close();
    }
    return petition;
  }

  Future<List<PetitionModel>> findNearPetitions() async {
    List<PetitionModel> petitions = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlNearPetition?idDevice=${prefs.idDevice}'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return petitions;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['petitions']) {
        petitions.add(PetitionModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('PetitionService petitions: $err');
      }
    } finally {
      client.close();
    }
    return petitions;
  }

  Future<List<PetitionModel>> history(String orderedAt) async {
    List<PetitionModel> petitions = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlOrderAtPetition$orderedAt'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return petitions;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['petitions']) {
        petitions.add(PetitionModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('PetitionService history: $err');
      }
    } finally {
      client.close();
    }
    return petitions;
  }

  Future<PetitionModel> collect(PetitionModel petition) async {
    var client = http.Client();
    try {
      final resp = await client
          .patch(Uri.parse('$kDomain$_urlCollect${petition.id}'), headers: {
        'Authorization': 'Bearer ${prefs.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      });
      if (resp.statusCode != 200) return petition;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return PetitionModel.fromJson(decodedResp['petition']);
    } catch (err) {
      if (kDebugMode) {
        print('PetitionService collect: $err');
      }
    } finally {
      client.close();
    }
    return petition;
  }

  Future<bool> deliver(PetitionModel petition) async {
    var client = http.Client();
    try {
      final resp = await client.patch(
          Uri.parse('$kDomain$_urlDeliver${petition.id}'),
          headers: {
            'Authorization': 'Bearer ${prefs.token}',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"scoreDeliveryman": petition.scoreDeliveryman}));
      if (resp.statusCode != 200) return false;
      return true;
    } catch (err) {
      if (kDebugMode) {
        print('PetitionService deliver: $err');
      }
    } finally {
      client.close();
    }
    return false;
  }

  Future<PetitionModel> cancel(PetitionModel petition) async {
    var client = http.Client();
    try {
      final resp = await client
          .patch(Uri.parse('$kDomain$_urlCancel${petition.id}'), headers: {
        'Authorization': 'Bearer ${prefs.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      });
      if (resp.statusCode != 200) return petition;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return PetitionModel.fromJson(decodedResp['petition']);
    } catch (err) {
      if (kDebugMode) {
        print('PetitionService cancel: $err');
      }
    } finally {
      client.close();
    }
    return petition;
  }

  Future<Map<String, dynamic>?> apply(PetitionModel petition) async {
    var client = http.Client();
    try {
      final resp = await client
          .patch(Uri.parse('$kDomain$_urlApply${petition.id}'), headers: {
        'Authorization': 'Bearer ${prefs.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      });
      return json.decode(resp.body);
    } catch (err) {
      if (kDebugMode) {
        print('PetitionService apply: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }

  Future<bool> activate(bool isOnline, latitude, longitude) async {
    var client = http.Client();
    try {
      final resp = await client.patch(
        Uri.parse('$kDomain$_urlActivate'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "idDevice": prefs.idDevice,
          "isOnline": isOnline,
          "latitude": latitude,
          "longitude": longitude,
        }),
      );
      if (resp.statusCode == 200) return true;
    } catch (err) {
      if (kDebugMode) {
        print('PetitionService apply: $err');
      }
    } finally {
      client.close();
    }
    return false;
  }
}
