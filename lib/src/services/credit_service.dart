import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urltopUpBalance = 'admin/credit/top-up-balance';

class CreditService {
  final prefs = PreferencesProvider();

  Future<Map<String, dynamic>?> topUpBalance(
      String phone, double amount) async {
    var client = http.Client();
    try {
      final resp = await client.post(
        Uri.parse('$kDomain$_urltopUpBalance'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "amount": amount,
          "phone": phone,
        }),
      );
      return json.decode(resp.body);
    } catch (err) {
      if (kDebugMode) {
        print('CreditService topUpBalance: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }
}
