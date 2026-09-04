import 'package:flutter/material.dart';
import 'package:app_meals/src/models/store_company_model.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/manager/hours/hours_controller.dart';
import 'package:app_meals/src/screens/manager/hours/widget/hours_card.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class HoursScreen extends StatelessWidget {
  HoursScreen({super.key, required this.storeCompany});

  final StoreCompanyModel storeCompany;

  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(storeCompany.name)),
      body: ChangeNotifierProvider<HoursController>.value(
        value: HoursController(storeCompany),
        child: Consumer<HoursController>(
          builder: (context, hoursController, child) => ModalProgressHUD(
            inAsyncCall: hoursController.inAsyncCall,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                    visible: hoursController.inAsyncCall,
                    child: const LinearProgressIndicator()),
                Expanded(
                  child: ListView.builder(
                    itemCount: hoursController.hours.length,
                    itemBuilder: (context, index) => HoursCard(hoursController,
                        hour: hoursController.hours[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
