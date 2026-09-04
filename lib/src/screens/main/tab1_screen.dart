import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';
import 'package:app_meals/src/screens/main/widget/filter_input.dart';
import 'package:app_meals/src/screens/main/widget/list_category.dart';
import 'package:app_meals/src/screens/main/widget/list_company.dart';
import 'package:app_meals/src/screens/main/widget/list_products.dart';
import 'package:app_meals/src/widgets/address_dropdown/address_dropdown.dart';
import 'package:app_meals/src/widgets/label.dart';
import 'package:provider/provider.dart';

class Tab1Screen extends StatefulWidget {
  const Tab1Screen({super.key});

  @override
  State<Tab1Screen> createState() => _Tab1ScreenState();
}

class _Tab1ScreenState extends State<Tab1Screen> with WidgetsBindingObserver {
  final endCompanyTop = 4;
  final startCompanyPopular = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Provider.of<Tab1Controller>(context, listen: false).load();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final tab1Controller = Provider.of<Tab1Controller>(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Visibility(
              visible: tab1Controller.inAsyncCall,
              child: const LinearProgressIndicator()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: kDefaultPadding)),
        SliverToBoxAdapter(child: FilterInput(tab1Controller: tab1Controller)),
        const SliverToBoxAdapter(
            child: SizedBox(height: kDefaultPadding * 0.3)),
        if (tab1Controller.inAsyncCall || tab1Controller.products.isNotEmpty)
          _products(tab1Controller),
        _categories(tab1Controller),
        _companies(
          tab1Controller,
          0,
          endCompanyTop,
          S.of(context).tCompanyTop,
          S.of(context).sTCompanyTop,
        ),
        if (tab1Controller.products.isNotEmpty) _products(tab1Controller),
        _companies(
          tab1Controller,
          startCompanyPopular,
          tab1Controller.companies.length,
          S.of(context).tCompanyPopular,
          S.of(context).sTCompanyPopular,
        ),
      ],
    );
  }

  _categories(Tab1Controller tab1Controller) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Label(S.of(context).tCategories, S.of(context).sTCategory),
          ListCategory(tab1Controller.categories)
        ],
      ),
    );
  }

  _companies(Tab1Controller tab1Controller, int start, int limit, String title,
      String subTitle) {
    int length = tab1Controller.companies.length;
    int end = start + limit;
    if (end > length) end = length;
    if (start >= length) return SliverToBoxAdapter(child: Container());
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Label(title, subTitle),
          ListCompany(tab1Controller.companies.sublist(start, end))
        ],
      ),
    );
  }

  _products(Tab1Controller tab1Controller) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Label(S.of(context).tFeatured, S.of(context).sFeatured),
          ListProducts(tab1Controller.products)
        ],
      ),
    );
  }
}

class SelectedAddress extends StatelessWidget {
  const SelectedAddress({
    super.key,
    required this.tab1Controller,
  }) ;

  final Tab1Controller tab1Controller;

  @override
  Widget build(BuildContext context) {
    return const AddressDropdown(isScreenMain: true);
  }
}
