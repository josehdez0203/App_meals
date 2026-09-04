import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/models/category_model.dart';
import 'package:app_meals/src/screens/main/tab1_controller.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:provider/provider.dart';

class ListCategory extends StatelessWidget {
  final List<CategoryModel> categories;

  const ListCategory(this.categories, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return _Category(category: categories[index]);
        },
      ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _card(BuildContext context) {
    final tab1Controller = Provider.of<Tab1Controller>(context);
    final card = Card(
      shadowColor: tab1Controller.selectedCategory.id == category.id
          ? kPrimaryColor
          : Colors.black54,
      elevation: tab1Controller.selectedCategory.id == category.id ? 2.7 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          children: <Widget>[
            Container(
              width: 37,
              height: 37,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: AvatarImage(image: category.image),
            ),
            const SizedBox(height: 2),
            Text(category.name),
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withValues(alpha: (0.6 * 255)),
                onTap: () {
                  tab1Controller.selectedCategory = category;
                }),
          ),
        ),
      ],
    );
  }
}
