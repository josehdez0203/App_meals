import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/group_model.dart';
import 'package:app_meals/src/services/group_service.dart';

class GroupDropdownController extends ChangeNotifier {
  final GroupService groupService = GroupService();
  final List<GroupModel> _groups = [];
  GroupModel _group = GroupModel(id: 0);

  SelectedListItem _dropdown =
      SelectedListItem(name: S.current.lselectGroup, value: '0');

  bool _inAsyncCall = false;
  bool _isGroupSelected = true;
  final List<SelectedListItem> _groupItems = [];

  GroupDropdownController(GroupModel? groupProduct) {
    if (groupProduct != null) {
      group = groupProduct;
      _dropdown =
          SelectedListItem(name: group.name, value: group.id.toString());
    }
    loadGroup();
  }

  bool get isGroupSelected => _isGroupSelected;

  set isGroupSelected(bool isGroupSelected) {
    _isGroupSelected = isGroupSelected;
    notifyListeners();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  List<GroupModel> get groups => _groups;

  GroupModel get group => _group;

  set group(GroupModel group) {
    _group = group;
    notifyListeners();
  }

  SelectedListItem get dropdown => _dropdown;

  Future<bool> setDropdown(SelectedListItem dropdown) async {
    _dropdown = dropdown;
    _group = _groups.firstWhere((adr) => adr.id.toString() == dropdown.value);
    notifyListeners();
    return true;
  }

  List<SelectedListItem> get groupItems => _groupItems;

  setGroupItems(List<GroupModel> groups) {
    _groupItems.clear();
    for (var group in groups) {
      _groupItems.add(
        SelectedListItem(name: group.name, value: group.id.toString()),
      );
    }
    notifyListeners();
  }

  loadGroup() async {
    inAsyncCall = true;
    final groups = await groupService.getGroups();
    _groups.clear();
    _groups.addAll(groups);
    setGroupItems(groups);
    inAsyncCall = false;
    notifyListeners();
  }
}
