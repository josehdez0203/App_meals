import 'package:flutter/material.dart';
import 'package:app_meals/constants/constants.dart';

class ImageIsEmpty extends StatelessWidget {
  final String message;
  final String image;

  const ImageIsEmpty(
    this.image, {
    super.key,
    this.message = '',
  }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: kDefaultPadding),
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(width: 280, image: AssetImage(image)),
            Text(message)
          ],
        ),
      ),
    );
  }
}
