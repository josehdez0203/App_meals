import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelper {
  latLngBounds(double ltA, double lgA, double ltB, double lgB) {
    dynamic slt, slg;
    dynamic nlt, nlg;

    if (ltA <= ltB) {
      slt = ltA;
      nlt = ltB;
    } else {
      slt = ltB;
      nlt = ltA;
    }
    if (lgA <= lgB) {
      slg = lgA;
      nlg = lgB;
    } else {
      slg = lgB;
      nlg = lgA;
    }
    return LatLngBounds(
        northeast: LatLng(nlt, nlg), southwest: LatLng(slt, slg));
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var R = 6378.137; //Radio de la tierra en km
    var dLat = rad(lat2 - lat1);
    var dLong = rad(lon2 - lon1);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.sin(dLong / 2) *
            math.sin(dLong / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = R * c * 1000; //Por mil para enviar en metros
    return d.toDouble(); //Retorna tres decimales
  }

  rad(x) {
    return x * math.pi / 180;
  }
}
