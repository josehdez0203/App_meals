import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/manager/product/product_controller.dart';
import 'package:app_meals/src/widgets/group_dropdown/group_dropdown_controller.dart';
import 'package:provider/provider.dart';

class GroupDropdown extends StatelessWidget {
  const GroupDropdown(this.productController, {super.key}) ;

  final ProductController productController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupDropdownController>.value(
      value: GroupDropdownController(productController.companyProduct.group),
      child: Consumer<GroupDropdownController>(
        builder: (context, groupDropdownController, child) => GestureDetector(
          onTap: () {
            if (groupDropdownController.inAsyncCall) return;
            onTextFieldTap(context, groupDropdownController);
          },
          child: Container(
            padding: const EdgeInsets.all(kDefaultPadding),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormField(
                  onSaved: (_) {
                    productController.companyProduct.group =
                        groupDropdownController.group;
                  },
                  validator: (_) {
                    if (groupDropdownController.group.id <= 0) {
                      groupDropdownController.isGroupSelected = false;
                      return '';
                    }
                    groupDropdownController.isGroupSelected = true;
                    return null;
                  },
                  builder: (_) => Row(
                    children: [
                      const Icon(Icons.food_bank_outlined,
                          color: kPrimaryColor),
                      const SizedBox(width: kDefaultPadding),
                      Text(groupDropdownController.dropdown.name),
                      Expanded(child: Container()),
                      const Icon(Icons.content_paste_go, color: kPrimaryColor),
                    ],
                  ),
                ),
                Visibility(
                    visible: !groupDropdownController.isGroupSelected,
                    child: const Divider(color: kErrorColor, thickness: 1.5)),
                Visibility(
                  visible: groupDropdownController.inAsyncCall,
                  child: const LinearProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onTextFieldTap(
      BuildContext context, GroupDropdownController groupDropdownController) {
    DropDownState(
      DropDown(
        bottomSheetTitle: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.food_bank_outlined, color: kPrimaryColor),
              const SizedBox(width: kDefaultPadding),
              Text(S.of(context).lselectGroup,
                  style: const TextStyle(fontSize: 17))
            ],
          ),
        ),
        data: groupDropdownController.groupItems,
        selectedItems: (List<dynamic> selectedList) async {
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              await groupDropdownController.setDropdown(item);
            }
          }
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }
}
