import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/request_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlNearRequest = 'manager/request/near/';
const _urlOrderAtRequest = 'manager/request/ordered-at/';
const _urlIdRequest = 'manager/request/id/';

class RequestService {
  final prefs = PreferencesProvider();

  Future<RequestModel> findRequest(RequestModel request) async {
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlIdRequest${request.id}'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return request;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return RequestModel.fromJson(decodedResp['request']);
    } catch (err) {
      if (kDebugMode) {
        print('RequestService findRequests: $err');
      }
    } finally {
      client.close();
    }
    return request;
  }

  Future<List<RequestModel>> findNearRequests() async {
    List<RequestModel> requests = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlNearRequest?idDevice=${prefs.idDevice}'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return requests;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['requests']) {
        requests.add(RequestModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('RequestService findNearRequests: $err');
      }
    } finally {
      client.close();
    }
    return requests;
  }

  Future<List<RequestModel>> history(String orderedAt) async {
    List<RequestModel> requests = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlOrderAtRequest$orderedAt'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return requests;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['requests']) {
        requests.add(RequestModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('RequestService history: $err');
      }
    } finally {
      client.close();
    }
    return requests;
  }
}
