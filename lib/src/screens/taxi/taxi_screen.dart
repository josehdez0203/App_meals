import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/company_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/taxi/taxi_controller.dart';
import 'package:app_meals/src/screens/taxi/widget/destination_point_button.dart';
import 'package:app_meals/src/screens/taxi/widget/pickup_point_button.dart';
import 'package:app_meals/src/screens/taxi/widget/to_button.dart';
import 'package:app_meals/src/widgets/head_autocomplete/head_autocomplete.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class TaxiScreen extends StatelessWidget {
  final CompanyModel company;

  const TaxiScreen(this.company, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaxiController>.value(
      value: TaxiController(company),
      child: Consumer<TaxiController>(
        builder: (context, taxiController, child) => ModalProgressHUD(
          inAsyncCall: taxiController.inAsyncCall,
          child: Scaffold(
            appBar: AppBar(
              title: !taxiController.establishedPickupLocation
                  ? Text(S.of(context).tPickupLocation)
                  : !taxiController.establishedDetinationLocation
                      ? Text(S.of(context).tDestination)
                      : Text(S.of(context).tRequestCab),
              actions: [
                IconButton(
                  onPressed: () {},
                  iconSize: 50,
                  icon: !taxiController.establishedPickupLocation
                      ? Image.asset('assets/travel.png')
                      : Image.asset('assets/start.png'),
                )
              ],
            ),
            body: Stack(
              children: [
                GoogleMap(
                  minMaxZoomPreference: const MinMaxZoomPreference(3, 16),
                  mapType: MapType.normal,
                  buildingsEnabled: false,
                  initialCameraPosition: taxiController.initialCameraPosition,
                  markers: taxiController.markers,
                  onMapCreated: taxiController.onMapCreated,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  onCameraMove: taxiController.onCameraMove,
                  onCameraIdle: taxiController.onCameraIdle,
                  onCameraMoveStarted: () => taxiController.initMove = true,
                  myLocationButtonEnabled: false,
                ),
                if (!taxiController.establishedPickupLocation ||
                    !taxiController.establishedDetinationLocation)
                  Center(
                      child: Icon(Icons.location_searching_outlined,
                          color: kPrimaryColor,
                          size: taxiController.initMove ? 50 : 30)),
                if (!taxiController.establishedPickupLocation)
                  PickUpPointButton(
                      prefs: PreferencesProvider(),
                      taxiController: taxiController),
                if (taxiController.establishedPickupLocation &&
                    !taxiController.establishedDetinationLocation)
                  DestinationPointButton(
                      prefs: PreferencesProvider(),
                      taxiController: taxiController),
                if (taxiController.establishedPickupLocation &&
                    taxiController.establishedDetinationLocation)
                  ToButton(
                      prefs: PreferencesProvider(),
                      taxiController: taxiController),
                if (!taxiController.establishedPickupLocation ||
                    !taxiController.establishedDetinationLocation)
                  HeadAutocomplete(
                    latitude: taxiController.taxi.from.location.x,
                    longitude: taxiController.taxi.from.location.y,
                    getController: taxiController.getController,
                  ),
                if (!taxiController.establishedPickupLocation ||
                    !taxiController.establishedDetinationLocation)
                  Positioned(
                    top: 120,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(10)),
                      child: IconButton(
                        onPressed: () {
                          taxiController.myLocation();
                        },
                        icon:
                            const Icon(Icons.my_location, color: kPrimaryColor),
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
