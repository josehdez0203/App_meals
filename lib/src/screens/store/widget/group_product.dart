import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/screens/store/store_controller.dart';

class GroupProduct extends StatelessWidget {
  const GroupProduct({
    super.key,
    required this.storeController,
  });

  final StoreController storeController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: kDefaultPadding * 0.2,
        bottom: kDefaultPadding * 0.2,
      ),
      width: double.infinity,
      height: 44,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: storeController.groups.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    storeController.groups[index].id ==
                            storeController.groupSelected.id
                        ? kPrimaryColor
                        : Colors.white),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kDefaultPadding),
                    side: const BorderSide(color: kPrimaryColor),
                  ),
                ),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0)),
                textStyle:
                    WidgetStateProperty.all(const TextStyle(fontSize: 14)),
              ),
              onPressed: () {
                storeController.groupSelected = storeController.groups[index];
              },
              child: Text(
                storeController.groups[index].name,
                style: TextStyle(
                    color: storeController.groups[index].id !=
                            storeController.groupSelected.id
                        ? kPrimaryColor
                        : Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
