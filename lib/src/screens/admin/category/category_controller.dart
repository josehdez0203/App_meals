import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/src/models/category_model.dart';
import 'package:app_meals/src/services/admin_category_service.dart';

/// Estado de la pantalla de categorias del administrador.
class CategoryController with ChangeNotifier {
  final AdminCategoryService categoryService = AdminCategoryService();

  final List<CategoryModel> _categories = [];
  CategoryModel _category = CategoryModel(id: 0);
  bool _inAsyncCall = false;

  List<CategoryModel> get categories => _categories;

  CategoryModel get category => _category;

  /// true cuando se esta editando una categoria existente (id > 0).
  bool get isEditing => _category.id > 0;

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  set category(CategoryModel category) {
    _category = category;
    notifyListeners();
  }

  Future<void> load() async {
    inAsyncCall = true;
    final loaded = await categoryService.getCategories();
    _categories
      ..clear()
      ..addAll(loaded);
    inAsyncCall = false;
    notifyListeners();
  }

  void startCreate() {
    category = CategoryModel(id: 0);
  }

  void startEdit(CategoryModel value) {
    // Copia para no modificar la fila de la lista hasta guardar.
    category = CategoryModel(
      id: value.id,
      name: value.name,
      image: value.image,
    );
  }

  /// Devuelve CodeError.none si el guardado fue correcto; en otro caso el
  /// codigo devuelto por el backend (por ejemplo nameUnique).
  Future<int> save() async {
    inAsyncCall = true;
    final response = isEditing
        ? await categoryService.update(
            _category.id, _category.name, _category.image)
        : await categoryService.create(_category.name, _category.image);
    inAsyncCall = false;

    if (response == null) return CodeError.unknown;
    if (response.containsKey('codeError')) {
      return response['codeError'] as int;
    }
    if (response.containsKey('id')) return CodeError.none;
    return CodeError.unknown;
  }
}
