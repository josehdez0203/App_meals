import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/hour_model.dart';
import 'package:app_meals/src/screens/manager/hours/hours_controller.dart';

class HoursCard extends StatelessWidget {
  const HoursCard(
    this.hoursController, {
    required this.hour,
    super.key,
  }) ;

  final HoursController hoursController;
  final HourModel hour;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              onPressed: () async {
                TimeOfDay selectedTime = TimeOfDay.fromDateTime(
                    DateTime(2022, 9, 7, hour.openHour, hour.openMinute));
                showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                  initialEntryMode: TimePickerEntryMode.input,
                  confirmText: S.of(context).bConfirm.toUpperCase(),
                  helpText: S.of(context).tOpeningTime,
                ).then((timeOfDay) {
                  if (timeOfDay == null) return;

                  String h = timeOfDay.hour < 10
                      ? '0${timeOfDay.hour}'
                      : '${timeOfDay.hour}';
                  String m = timeOfDay.minute < 10
                      ? '0${timeOfDay.minute}'
                      : '${timeOfDay.minute}';

                  hour.open = '$h:$m:00';
                  hoursController.updateHour(hour);
                });
              },
              icon: const Icon(Icons.lock_open_outlined, color: kPrimaryColor),
            ),
            trailing: IconButton(
              onPressed: () {
                TimeOfDay selectedTime = TimeOfDay.fromDateTime(
                    DateTime(2022, 9, 7, hour.closeHour, hour.closeMinute));
                showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                  initialEntryMode: TimePickerEntryMode.input,
                  confirmText: S.of(context).bConfirm.toUpperCase(),
                  helpText: S.of(context).tClosingTime,
                ).then((timeOfDay) {
                  if (timeOfDay == null) return;

                  String h = timeOfDay.hour < 10
                      ? '0${timeOfDay.hour}'
                      : '${timeOfDay.hour}';
                  String m = timeOfDay.minute < 10
                      ? '0${timeOfDay.minute}'
                      : '${timeOfDay.minute}';

                  hour.close = '$h:$m:59';
                  hoursController.updateHour(hour);
                });
              },
              icon: const Icon(Icons.lock_outline),
            ),
            title: Text(hour.date(context)),
            subtitle: Row(
              children: [
                Text(
                  hour.open,
                  style: const TextStyle(color: kPrimaryColor),
                ),
                const Text(' => '),
                Text(hour.close)
              ],
            ),
          ),
          const Divider(color: kPrimaryColor, thickness: 1)
        ],
      ),
    );
  }
}
