import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/category_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';

const _urlCategory = 'admin/category';

/// Cliente de los endpoints de categorias del rol admin:
/// GET y POST `admin/category`, PATCH `admin/category/{id}`.
///
/// El backend exige el rol admin; si el token no lo tiene responde 403 y los
/// metodos devuelven null.
class AdminCategoryService {
  final prefs = PreferencesProvider();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${prefs.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      };

  Future<List<CategoryModel>> getCategories() async {
    List<CategoryModel> categories = [];
    var client = http.Client();
    try {
      final resp = await client.get(
        Uri.parse('$kDomain$_urlCategory'),
        headers: _headers,
      );
      if (resp.statusCode != 200) return categories;
      final decoded = json.decode(resp.body);
      if (decoded is! List) return categories;
      for (var item in decoded) {
        categories.add(CategoryModel.fromJson(item));
      }
    } catch (err) {
      if (kDebugMode) {
        print('AdminCategoryService getCategories: $err');
      }
    } finally {
      client.close();
    }
    return categories;
  }

  Future<Map<String, dynamic>?> create(String name, String image) =>
      _save(isNew: true, id: 0, name: name, image: image);

  Future<Map<String, dynamic>?> update(int id, String name, String image) =>
      _save(isNew: false, id: id, name: name, image: image);

  Future<Map<String, dynamic>?> _save({
    required bool isNew,
    required int id,
    required String name,
    required String image,
  }) async {
    var client = http.Client();
    try {
      final uri = Uri.parse(
          isNew ? '$kDomain$_urlCategory' : '$kDomain$_urlCategory/$id');
      final body = jsonEncode({
        'name': name.trim(),
        'image': image.trim(),
      });
      final resp = isNew
          ? await client.post(uri, headers: _headers, body: body)
          : await client.patch(uri, headers: _headers, body: body);
      final decoded = json.decode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (err) {
      if (kDebugMode) {
        print('AdminCategoryService save: $err');
      }
    } finally {
      client.close();
    }
    return null;
  }
}
