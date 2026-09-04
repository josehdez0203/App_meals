import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/constants/status_constant.dart';
import 'package:app_meals/src/screens/deliveryman/petition/petition_controller.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/button_client_direction.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/button_store_direction.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/floating_button_call.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/floating_button_cancel.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/floating_button_whatsapp.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/floating_head.dart';
import 'package:app_meals/src/screens/deliveryman/petition/widget/floating_sheet_bottom.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';

class ContentPetition extends StatefulWidget {
  const ContentPetition(
    this.petitionController, {
    super.key,
  }) ;

  final PetitionController petitionController;

  @override
  State<ContentPetition> createState() => _ContentPetitionState();
}

class _ContentPetitionState extends State<ContentPetition>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 2100),
        () => widget.petitionController.centerMap(),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        widget.petitionController.refreshPetition();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: widget.petitionController.inAsyncCall,
      child: Scaffold(
        appBar: AppBar(actions: [_buttonAppBar(widget.petitionController)]),
        body: Stack(
          children: [
            GoogleMap(
              minMaxZoomPreference: const MinMaxZoomPreference(3, 16),
              markers: widget.petitionController.markers,
              mapType: MapType.normal,
              buildingsEnabled: false,
              compassEnabled: true,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition:
                  widget.petitionController.initialCameraPosition,
              onMapCreated: widget.petitionController.onMapCreated,
            ),
            FloatingHead(petitionController: widget.petitionController),
            FloatingButtonCall(petition: widget.petitionController.petition),
            FloatingButtonWhatsapp(
                petition: widget.petitionController.petition),
            FloatingButtonCancel(petitionController: widget.petitionController),
            FloatingSheetBottom(petitionController: widget.petitionController),
          ],
        ),
      ),
    );
  }

  Widget _buttonAppBar(PetitionController petitionController) {
    switch (petitionController.petition.status) {
      case StatusOrder.assigned:
        return ButtonStoreDirection(petition: petitionController.petition);
      case StatusOrder.taken:
        return ButtonClientDirection(petition: petitionController.petition);
      default:
        return Container();
    }
  }
}
