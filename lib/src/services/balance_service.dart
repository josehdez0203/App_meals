import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/balance_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlBalance = 'client/balance';

class BalanceService {
  final prefs = PreferencesProvider();

  Future<BalanceModel?> getBalance() async {
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlBalance'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode == 200) {
        Map<String, dynamic> decodedResp = json.decode(resp.body);
        return BalanceModel.fromJson(decodedResp['balance']);
      }
    } catch (err) {
      if (kDebugMode) {
        print('BalanceService getBalance: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }
}
