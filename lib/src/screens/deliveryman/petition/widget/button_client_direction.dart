import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/launch.dart';
import 'package:app_meals/src/models/petition_model.dart';

class ButtonClientDirection extends StatelessWidget {
  const ButtonClientDirection({
    super.key,
    required this.petition,
  }) ;

  final PetitionModel petition;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))),
      label: Text(
        S.of(context).bRouteClient,
        style: const TextStyle(color: kPrimaryColor),
      ),
      icon: const Icon(
        Icons.person_pin_circle_outlined,
        color: kPrimaryColor,
        size: 33,
      ),
      onPressed: () {
        openMapDirections(petition.location.x, petition.location.y);
      },
    );
  }
}
