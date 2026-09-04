import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/manager/enrollment/enrollment_controller.dart';
import 'package:app_meals/src/screens/manager/enrollment/widget/footer_button.dart';
import 'package:app_meals/src/widgets/head_autocomplete/head_autocomplete.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class EnrollmentScreen extends StatelessWidget {
  EnrollmentScreen({super.key});

  final prefs = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    final enrollmentController = Provider.of<EnrollmentController>(context);
    return ModalProgressHUD(
      inAsyncCall: enrollmentController.inAsyncCall,
      child: Scaffold(
        appBar: AppBar(title: Text(S.of(context).tRegisterStore)),
        body: Stack(
          children: [
            GoogleMap(
              minMaxZoomPreference: const MinMaxZoomPreference(3, 16),
              mapType: MapType.normal,
              buildingsEnabled: false,
              initialCameraPosition: enrollmentController.initialCameraPosition,
              onMapCreated: enrollmentController.onMapCreated,
              myLocationEnabled: true,
              compassEnabled: true,
              onCameraMove: enrollmentController.onCameraMove,
              myLocationButtonEnabled: false,
            ),
            const Center(
                child: Icon(Icons.location_searching_outlined,
                    color: kPrimaryColor, size: 30)),
            const FooterButton(),
            HeadAutocomplete(
              latitude: enrollmentController.enrollment.location.x,
              longitude: enrollmentController.enrollment.location.y,
              getController: enrollmentController.getController,
            ),
            Positioned(
              top: 120,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  onPressed: () {
                    enrollmentController.myLocation();
                  },
                  icon: const Icon(Icons.my_location, color: kPrimaryColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
