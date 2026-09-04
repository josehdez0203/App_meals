import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/group_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlGroup = 'admin/group';

class GroupService {
  final prefs = PreferencesProvider();

  Future<List<GroupModel>> getGroups() async {
    List<GroupModel> groups = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlGroup'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return groups;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['groups']) {
        groups.add(GroupModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('GroupService getGroups: $err');
      }
    } finally {
      client.close();
    }
    return groups;
  }
}
