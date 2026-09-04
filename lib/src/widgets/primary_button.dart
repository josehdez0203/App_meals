import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color = kPrimaryColor,
    this.padding = const EdgeInsets.all(kDefaultPadding * 0.85),
  }) ;

  final String text;
  final VoidCallback onPressed;
  final Color color;
  final EdgeInsets padding;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding * .5),
      child: MaterialButton(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        padding: padding,
        color: color,
        minWidth: double.infinity,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (icon != null) const SizedBox(width: 20),
            Text(text, style: const TextStyle(color: Colors.white)),
            if (icon != null) Icon(icon, color: Colors.white)
          ],
        ),
      ),
    );
  }
}
