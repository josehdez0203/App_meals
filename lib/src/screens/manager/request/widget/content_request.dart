import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_meals/src/common/status_label.dart';
import 'package:app_meals/src/screens/manager/request/request_controller.dart';
import 'package:app_meals/src/screens/manager/request/widget/floating_head.dart';
import 'package:app_meals/src/screens/manager/request/widget/floating_sheet_bottom.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';

class ContentRequest extends StatefulWidget {
  const ContentRequest(
    this.requestController, {
    super.key,
  }) ;

  final RequestController requestController;

  @override
  State<ContentRequest> createState() => _ContentRequestState();
}

class _ContentRequestState extends State<ContentRequest>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 2100),
        () => widget.requestController.centerMap(),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        widget.requestController.refreshRequest();
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
      inAsyncCall: widget.requestController.inAsyncCall,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            statusOrderLabel(
              widget.requestController.request.status,
              widget.requestController.request.store.company.type,
            ),
            maxLines: 2,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              minMaxZoomPreference: const MinMaxZoomPreference(3, 16),
              markers: widget.requestController.markers,
              mapType: MapType.normal,
              buildingsEnabled: false,
              compassEnabled: true,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition:
                  widget.requestController.initialCameraPosition,
              onMapCreated: widget.requestController.onMapCreated,
            ),
            FloatingHead(requestController: widget.requestController),
            FloatingSheetBottom(requestController: widget.requestController),
          ],
        ),
      ),
    );
  }
}
