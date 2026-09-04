import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/company_product_model.dart';
import 'package:app_meals/src/models/store_company_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/manager/hours/hours_screen.dart';
import 'package:app_meals/src/screens/manager/product/product_controller.dart';
import 'package:app_meals/src/screens/manager/product/product_screen.dart';
import 'package:app_meals/src/screens/manager/products/products_controller.dart';
import 'package:app_meals/src/screens/manager/products/widget/products_card.dart';
import 'package:app_meals/src/widgets/secondary_button.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  ProductsScreen({super.key, required this.storeCompany});

  final StoreCompanyModel storeCompany;

  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(storeCompany.name),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        HoursScreen(storeCompany: storeCompany),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month_outlined))
        ],
      ),
      body: ChangeNotifierProvider<ProductsController>.value(
        value: ProductsController(storeCompany),
        child: Consumer<ProductsController>(
          builder: (context, productsController, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                  visible: productsController.inAsyncCall,
                  child: const LinearProgressIndicator()),
              Expanded(
                  child: ListView.builder(
                itemCount: productsController.products.length,
                itemBuilder: (context, index) => ProductsCard(
                    productsController,
                    companyProduct: productsController.products[index]),
              )),
              SecondaryButton(
                color: Theme.of(context).colorScheme.secondary,
                text: S.of(context).bNewProduct,
                onPressed: () {
                  final productController =
                      Provider.of<ProductController>(context, listen: false);
                  productController.companyProduct = CompanyProductModel(id: 0);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductScreen(productsController),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
