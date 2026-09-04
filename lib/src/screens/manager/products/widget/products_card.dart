import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/company_product_model.dart';
import 'package:app_meals/src/screens/manager/product/product_controller.dart';
import 'package:app_meals/src/screens/manager/product/product_screen.dart';
import 'package:app_meals/src/screens/manager/products/products_controller.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:provider/provider.dart';

class ProductsCard extends StatelessWidget {
  const ProductsCard(
    this.productsController, {
    required this.companyProduct,
    super.key,
  }) ;

  final ProductsController productsController;
  final CompanyProductModel companyProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              final productController =
                  Provider.of<ProductController>(context, listen: false);
              productController.companyProduct = companyProduct;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductScreen(productsController),
                ),
              );
            },
            leading: AvatarImage(image: companyProduct.image),
            title: Text(companyProduct.name),
            subtitle: Text(companyProduct.description),
          ),
          const Divider(color: kPrimaryColor, thickness: 1)
        ],
      ),
    );
  }
}
