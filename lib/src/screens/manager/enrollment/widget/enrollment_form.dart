import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/file_helper.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/manager/enrollment/enrollment_controller.dart';
import 'package:app_meals/src/screens/manager/enrollment/widget/address_input.dart';
import 'package:app_meals/src/screens/manager/enrollment/widget/contact_input.dart';
import 'package:app_meals/src/screens/manager/enrollment/widget/email_input.dart';
import 'package:app_meals/src/screens/manager/enrollment/widget/name_input.dart';
import 'package:app_meals/src/screens/manager/enrollment/widget/save_button.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/category_dropdown/category_dropdown.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:app_meals/src/widgets/upload_file/upload_file.dart';
import 'package:provider/provider.dart';

class EnrollmentForm extends StatelessWidget {
  EnrollmentForm({super.key}) ;
  final prefs = PreferencesProvider();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final enrollmentController = Provider.of<EnrollmentController>(context);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).tRegisterStore)),
      body: ModalProgressHUD(
        inAsyncCall: enrollmentController.inAsyncCall,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                  visible: enrollmentController.inAsyncCall,
                  child: const LinearProgressIndicator()),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Column(
                      children: [
                        AvatarImage(
                            width: 200,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(kDefaultPadding * 0.5)),
                            image: enrollmentController.enrollment.image),
                        ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => UploadFile((image) async {
                                enrollmentController.inAsyncCall = true;
                                String imageUpload = await uploadFile(
                                    image,
                                    'store',
                                    '${prefs.user.id}-${DateTime.now().toIso8601String()}',
                                    kTargetWidthStore);
                                enrollmentController.enrollment.image =
                                    imageUpload;
                                enrollmentController.inAsyncCall = false;
                              }),
                            );
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
                        ),
                        const SizedBox(height: kDefaultPadding),
                        CategoryDropdown(enrollmentController.category),
                        const SizedBox(height: kDefaultPadding),
                        NameInput(enrollmentController: enrollmentController),
                        const SizedBox(height: kDefaultPadding),
                        ContactInput(
                            enrollmentController: enrollmentController),
                        const SizedBox(height: kDefaultPadding),
                        EmailInput(enrollmentController: enrollmentController),
                        const SizedBox(height: kDefaultPadding),
                        AddressInput(
                            enrollmentController: enrollmentController),
                        const SizedBox(height: kDefaultPadding * 10),
                      ],
                    ),
                  ),
                ),
              ),
              SaveButton(
                  formKey: _formKey, enrollmentController: enrollmentController)
            ],
          ),
        ),
      ),
    );
  }
}
