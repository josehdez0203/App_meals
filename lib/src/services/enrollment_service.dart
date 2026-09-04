import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/category_model.dart';
import 'package:app_meals/src/models/enrollment_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlGetCategories = 'manager/enrollment/get-categories';
const _urlEnrollment = 'manager/enrollment';

class EnrollmentService {
  final prefs = PreferencesProvider();

  Future<List<CategoryModel>> getCategories() async {
    List<CategoryModel> categories = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlGetCategories'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
        },
      );
      if (resp.statusCode != 200) return categories;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      for (var item in decodedResp['categories']) {
        categories.add(CategoryModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('EnrollmentService getCategories: $err');
      }
    } finally {
      client.close();
    }
    return categories;
  }

  Future<Map<String, dynamic>?> enrollment(
      EnrollmentModel enrollmentModel, int categoryId) async {
    var client = http.Client();
    try {
      final resp = await client.post(
        Uri.parse('$kDomain$_urlEnrollment'),
        headers: {
          'Authorization': 'Bearer ${prefs.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: enrollmentModel.toHttpBodyEnrollment(categoryId),
      );
      return json.decode(resp.body);
    } catch (err) {
      if (kDebugMode) {
        print('EnrollmentService enrollment: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }
}
