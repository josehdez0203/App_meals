import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/widgets/upload_file/upload_file_controller.dart';
import 'package:provider/provider.dart';

class UploadFile extends StatelessWidget {
  UploadFile(this.onUnpload, {super.key});

  final ImagePicker picker = ImagePicker();
  final Function onUnpload;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UploadFileController>.value(
      value: UploadFileController(),
      child: Consumer<UploadFileController>(
        builder: (context, uploadFileController, child) => AlertDialog(
          insetPadding: const EdgeInsets.all(kDefaultPadding * 1.6),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 400.0, height: 10.0),
                uploadFileController.getImage() == null
                    ? Container()
                    : Image.file(uploadFileController.getImage()!,
                        width: 260, height: 260, fit: BoxFit.cover),
                ElevatedButton(
                  onPressed: () async {
                    XFile? xlife =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (xlife == null) return;
                    uploadFileController.image = File(xlife.path);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera_outlined),
                      const SizedBox(width: kDefaultPadding * .5),
                      Text(S.of(context).bSelectPhoto),
                      const SizedBox(width: kDefaultPadding * .5),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
              onPressed: () {
                if (uploadFileController.getImage() == null) return;
                Navigator.of(context).pop();
                onUnpload(uploadFileController.getImage()!);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload_outlined),
                  const SizedBox(width: kDefaultPadding * .5),
                  Text(S.of(context).bUpload),
                  const SizedBox(width: kDefaultPadding * .5),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
