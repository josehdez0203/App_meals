import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/address_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/address/address_controller.dart';
import 'package:app_meals/src/screens/address/widget/footer_button.dart';
import 'package:app_meals/src/widgets/head_autocomplete/head_autocomplete.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatelessWidget {
  final AddressModel address;

  AddressScreen({super.key, required this.address});

  final prefs = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddressController>.value(
      value: AddressController(address),
      child: Consumer<AddressController>(
        builder: (context, addressController, child) => ModalProgressHUD(
          inAsyncCall: addressController.inAsyncCall,
          child: Scaffold(
            appBar: AppBar(title: Text(S.of(context).tAddress)),
            body: Stack(
              children: [
                GoogleMap(
                  minMaxZoomPreference: const MinMaxZoomPreference(3, 16),
                  mapType: MapType.normal,
                  buildingsEnabled: false,
                  initialCameraPosition:
                      addressController.initialCameraPosition,
                  onMapCreated: addressController.onMapCreated,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  onCameraMove: addressController.onCameraMove,
                  myLocationButtonEnabled: false,
                ),
                const Center(
                    child: Icon(Icons.location_searching_outlined,
                        color: kPrimaryColor, size: 30)),
                FooterButton(
                    prefs: prefs, addressController: addressController),
                HeadAutocomplete(
                  latitude: addressController.address.location.x,
                  longitude: addressController.address.location.y,
                  getController: addressController.getController,
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
                        addressController.myLocation();
                      },
                      icon: const Icon(Icons.my_location, color: kPrimaryColor),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
