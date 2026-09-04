import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';

String? validateEmail(BuildContext context, String email) {
  String value = email.trim();
  if (value.length < 8) return S.of(context).eValidatoEmail;
  bool emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(value);
  if (!emailValid) return S.of(context).eValidatoEmail;
  return null;
}

String? validatePrice(BuildContext context, String value) {
  value = value.trim();
  value = value.replaceFirst(',', '.');
  if (value.isEmpty) return S.of(context).eValidatoAmount;
  bool priceValid = RegExp(r"^[0-9+]").hasMatch(value);
  if (!priceValid) return S.of(context).eValidatoAmount;
  try {
    double.parse(value).toStringAsFixed(2);
  } catch (err) {
    return S.of(context).eValidatoAmount;
  }
  return null;
}
