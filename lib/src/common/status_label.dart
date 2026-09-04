import 'package:app_meals/constants/status_constant.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';

String statusOrderLabel(int status, int companyType) {
  if (companyType == TypesCompany.store) {
    switch (status) {
      case StatusOrder.started:
        return S.current.lStatusOrderStarted;
      case StatusOrder.assigned:
        return S.current.lStatusOrderAssigned;
      case StatusOrder.taken:
        return S.current.lStatusOrderTaken;
      case StatusOrder.delivered:
        return S.current.lStatusOrderDelivered;
      case StatusOrder.cancelled:
        return S.current.lStatusOrderCancelled;
      case StatusOrder.qualified:
        return S.current.lStatusOrderQualified;
      default:
        return 'Unknown';
    }
  } else if (companyType == TypesCompany.taxi) {
    switch (status) {
      case StatusOrder.started:
        return S.current.lStatusTaxiStarted;
      case StatusOrder.assigned:
        return S.current.lStatusTaxiAssigned;
      case StatusOrder.taken:
        return S.current.lStatusTaxiTaken;
      case StatusOrder.delivered:
        return S.current.lStatusTaxiDelivered;
      case StatusOrder.cancelled:
        return S.current.lStatusTaxiCancelled;
      case StatusOrder.qualified:
        return S.current.lStatusTaxiQualified;
      default:
        return 'Unknown';
    }
  } else {
    return 'Unknown';
  }
}
