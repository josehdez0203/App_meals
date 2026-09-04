import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = kSecondaryColor,
    this.padding = const EdgeInsets.all(kDefaultPadding * 0.85),
  });

  final String text;
  final VoidCallback onPressed;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding * .5),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40))),
            side: const BorderSide(color: kSecondaryColor),
            padding: const EdgeInsets.only(
                top: kDefaultPadding * .9, bottom: kDefaultPadding * .9)),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: kSecondaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
