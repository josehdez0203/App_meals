import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';

class FilterInput extends StatelessWidget {
  const FilterInput({
    super.key,
    required this.tab1Controller,
  }) ;

  final Tab1Controller tab1Controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.75),
      margin: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.5),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          icon: const Icon(Icons.search_outlined, color: kPrimaryColor),
          hintText: S.of(context).hFilter,
          border: InputBorder.none,
        ),
        onChanged: (value) {
          tab1Controller.filterCompanies(value);
        },
      ),
    );
  }
}
