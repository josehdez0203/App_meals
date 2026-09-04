import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/category_model.dart';
import 'package:app_meals/src/services/enrollment_service.dart';

class CategoryDropdownController extends ChangeNotifier {
  final EnrollmentService enrollmentService = EnrollmentService();
  final List<CategoryModel> _categories = [];
  CategoryModel _category = CategoryModel(id: 0);

  SelectedListItem _dropdown =
      SelectedListItem(name: S.current.lselectCategory, value: '0');
  bool _inAsyncCall = false;
  bool _isCategorySelected = true;
  final List<SelectedListItem> _categoryItems = [];

  CategoryDropdownController() {
    loadCategory();
  }

  bool get isCategorySelected => _isCategorySelected;

  set isCategorySelected(bool isCategorySelected) {
    _isCategorySelected = isCategorySelected;
    notifyListeners();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  List<CategoryModel> get categories => _categories;

  CategoryModel get category => _category;

  set category(CategoryModel category) {
    _category = category;
    notifyListeners();
  }

  SelectedListItem get dropdown => _dropdown;

  Future<bool> setDropdown(SelectedListItem dropdown) async {
    _dropdown = dropdown;
    _category =
        _categories.firstWhere((adr) => adr.id.toString() == dropdown.value);
    notifyListeners();
    return true;
  }

  List<SelectedListItem> get categoryItems => _categoryItems;

  setCategoryItems(List<CategoryModel> categories) {
    _categoryItems.clear();
    for (var category in categories) {
      _categoryItems.add(
        SelectedListItem(name: category.name, value: category.id.toString()),
      );
    }
    notifyListeners();
  }

  loadCategory() async {
    inAsyncCall = true;
    final categories = await enrollmentService.getCategories();
    _categories.clear();
    _categories.addAll(categories);
    setCategoryItems(categories);
    inAsyncCall = false;
    notifyListeners();
  }
}
