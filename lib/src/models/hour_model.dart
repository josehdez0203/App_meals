import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';

HourModel hourstModelFromJson(String str) =>
    HourModel.fromJson(json.decode(str));

String hourstModelToJson(HourModel data) => json.encode(data.toJson());

class HourModel {
  HourModel({
    required this.id,
    required this.day,
    required this.open,
    required this.close,
  });

  int id;
  int day;
  String open;
  String close;

  int get closeHour {
    return int.parse(close.split(':')[0]);
  }

  int get closeMinute {
    return int.parse(close.split(':')[1]);
  }

  int get openHour {
    return int.parse(open.split(':')[0]);
  }

  int get openMinute {
    return int.parse(open.split(':')[1]);
  }

  String date(BuildContext context) {
    switch (day) {
      case 1:
        return S.of(context).lMonday;
      case 2:
        return S.of(context).lTuesday;
      case 3:
        return S.of(context).lWednesday;
      case 4:
        return S.of(context).lThursday;
      case 5:
        return S.of(context).lFriday;
      case 6:
        return S.of(context).lSaturday;
      case 0:
        return S.of(context).lSunday;
      default:
        return '';
    }
  }

  factory HourModel.fromJson(Map<String, dynamic> json) => HourModel(
        id: json["id"],
        day: json["day"],
        open: json["open"],
        close: json["close"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "day": day,
        "open": open,
        "close": close,
      };

  Object toHttpBodyUpdate() => jsonEncode({
        "open": open.trim(),
        "close": close.trim(),
      });
}
