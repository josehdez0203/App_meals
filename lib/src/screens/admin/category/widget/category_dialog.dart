import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/file_helper.dart';
import 'package:app_meals/src/screens/admin/category/category_controller.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/upload_file/upload_file.dart';

/// Formulario de alta y edicion de categorias.
///
/// La imagen se sube a Firebase Storage con la misma utilidad que el alta de
/// productos: se recorta a cuadrado, se redimensiona y se guarda en la carpeta
/// `category/`. Al editar, si no se elige una imagen nueva se conserva la actual.
///
/// Devuelve true al guardar y false/null si se cancela.
class CategoryDialog extends StatefulWidget {
  const CategoryDialog(this.categoryController, {super.key});

  final CategoryController categoryController;

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String _image;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _image = widget.categoryController.category.image;
  }

  Future<void> _pickImage() async {
    // Se capturan antes de abrir el dialogo: dentro del callback el contexto
    // del selector ya estaria desmontado.
    final messenger = ScaffoldMessenger.of(context);
    final strings = S.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => UploadFile((File file) async {
        setState(() => _uploading = true);
        final String url = await uploadFile(
          file,
          'categories',
          'category-${DateTime.now().toIso8601String()}',
          kTargetWidthCategory,
        );
        if (!mounted) return;
        setState(() {
          _image = url;
          _uploading = false;
        });
        if (url.isEmpty) {
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: kErrorColor,
              content: Text(strings.errUnknown),
            ),
          );
        }
      }),
    );
  }

  void _save() {
    FocusScope.of(context).requestFocus(FocusNode());
    formKey.currentState!.save();
    if (!formKey.currentState!.validate()) return;

    // El backend exige 7 caracteres como minimo en la imagen.
    if (_image.trim().length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kErrorColor,
          content: Text(S.of(context).errPleaseUploadImage),
        ),
      );
      return;
    }
    widget.categoryController.category.image = _image.trim();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryController.isEditing;
    return AlertDialog(
      insetPadding: const EdgeInsets.all(kDefaultPadding * 1.6),
      title: Text(
        isEditing ? S.of(context).tEditCategory : S.of(context).bNewCategory,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 0.8,
        vertical: kDefaultPadding,
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarImage(
              width: 140,
              borderRadius: const BorderRadius.all(
                Radius.circular(kDefaultPadding),
              ),
              image: _image,
            ),
            const SizedBox(height: kDefaultPadding * 0.5),
            if (_uploading) const LinearProgressIndicator(),
            ElevatedButton(
              onPressed: _uploading ? null : _pickImage,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera_outlined),
                  const SizedBox(width: kDefaultPadding * .5),
                  Text(S.of(context).bSelectPhoto),
                  const SizedBox(width: kDefaultPadding * .5),
                ],
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            _CategoryField(
              icon: Icons.category_outlined,
              hint: S.of(context).hCategoryName,
              initialValue: widget.categoryController.category.name,
              onSaved: (value) =>
                  widget.categoryController.category.name = value,
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.reply_outlined),
              const SizedBox(width: kDefaultPadding * .5),
              Text(S.of(context).bCancel),
              const SizedBox(width: kDefaultPadding * .5),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save_as_outlined),
              const SizedBox(width: kDefaultPadding * .5),
              Text(S.of(context).bSaveChanges),
              const SizedBox(width: kDefaultPadding * .5),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.icon,
    required this.hint,
    required this.initialValue,
    required this.onSaved,
  });

  final IconData icon;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.75),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: (0.5 * 255)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        initialValue: initialValue,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          icon: Icon(icon, color: kPrimaryColor),
          hintText: hint,
          border: InputBorder.none,
        ),
        onSaved: (value) => onSaved(value!.trim()),
        validator: (value) {
          // El backend exige 7 caracteres como minimo en name e image.
          if (value == null || value.trim().length < 7) {
            return S.of(context).eValidatoCharacters(7);
          }
          return null;
        },
      ),
    );
  }
}
