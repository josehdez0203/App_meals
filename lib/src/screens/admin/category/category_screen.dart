import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/category_model.dart';
import 'package:app_meals/src/screens/admin/category/category_controller.dart';
import 'package:app_meals/src/screens/admin/category/widget/category_dialog.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:provider/provider.dart';

/// Listado y edicion de categorias. Solo se llega aqui desde el menu lateral,
/// cuya entrada es visible unicamente para el rol admin (el backend tambien lo
/// exige).
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CategoryController>(
      create: (_) => CategoryController()..load(),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).tCategories),
        actions: [
          IconButton(
            tooltip: S.of(context).bNewCategory,
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(context, categoryController, null),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: categoryController.inAsyncCall,
        child: categoryController.categories.isEmpty
            ? const _EmptyCategories()
            : ListView.builder(
                itemCount: categoryController.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryController.categories[index];
                  return _CategoryTile(
                    category: category,
                    onTap: () =>
                        _openForm(context, categoryController, category),
                  );
                },
              ),
      ),
    );
  }
}

Future<void> _openForm(
  BuildContext context,
  CategoryController categoryController,
  CategoryModel? category,
) async {
  if (category == null) {
    categoryController.startCreate();
  } else {
    categoryController.startEdit(category);
  }

  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => CategoryDialog(categoryController),
  );
  if (saved != true || !context.mounted) return;

  final codeError = await categoryController.save();
  if (!context.mounted) return;

  final s = S.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (codeError == CodeError.none) {
    messenger.showSnackBar(SnackBar(
      backgroundColor: kPrimaryColor,
      content: Text(s.mRChangesMadeCorrectly),
    ));
    await categoryController.load();
  } else if (codeError == CodeError.nameUnique) {
    messenger.showSnackBar(SnackBar(
      backgroundColor: kErrorColor,
      content: Text(s.errNameUnique(categoryController.category.name)),
    ));
  } else {
    messenger.showSnackBar(SnackBar(
      backgroundColor: kErrorColor,
      content: Text(s.errUnknown),
    ));
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding, vertical: kDefaultPadding * 0.25),
      child: ListTile(
        leading: AvatarImage(
          width: 40,
          borderRadius: const BorderRadius.all(Radius.circular(kDefaultPadding)),
          image: category.image,
        ),
        title: Text(category.name),
        subtitle: Text('#${category.id}'),
        trailing: const Icon(Icons.edit_outlined, color: kPrimaryColor),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined,
                size: 72, color: kPrimaryColor.withValues(alpha: (0.5 * 255))),
            const SizedBox(height: kDefaultPadding),
            Text(S.of(context).mNoCategories, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
