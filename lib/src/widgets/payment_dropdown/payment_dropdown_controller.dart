import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/payment_model.dart';

class PaymentDropdownController extends ChangeNotifier {
  final List<PaymentModel> _payments = [];
  PaymentModel _payment = PaymentModel(name: '', type: TypesPayment.none);

  SelectedListItem _dropdown = SelectedListItem(
      name: S.current.lselectPayment, value: TypesPayment.none.toString());
  bool _inAsyncCall = false;
  bool _isPaymentSelected = true;
  final List<SelectedListItem> _paymentItems = [];

  PaymentDropdownController() {
    loadPayment();
  }

  bool get isPaymentSelected => _isPaymentSelected;

  set isPaymentSelected(bool isPaymentSelected) {
    _isPaymentSelected = isPaymentSelected;
    notifyListeners();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  List<PaymentModel> get payments => _payments;

  PaymentModel get payment => _payment;

  set payment(PaymentModel payment) {
    _payment = payment;
    notifyListeners();
  }

  SelectedListItem get dropdown => _dropdown;

  Future<bool> setDropdown(SelectedListItem dropdown) async {
    _dropdown = dropdown;
    _payment =
        _payments.firstWhere((adr) => adr.type.toString() == dropdown.value);
    notifyListeners();
    return true;
  }

  List<SelectedListItem> get paymentItems => _paymentItems;

  setPaymentItems(List<PaymentModel> payments) {
    _paymentItems.clear();
    for (var payment in payments) {
      _paymentItems.add(
        SelectedListItem(name: payment.name, value: payment.type.toString()),
      );
    }
    notifyListeners();
  }

  final PaymentModel paymentCash =
      PaymentModel(name: S.current.lPayCash, type: TypesPayment.cash);
  final PaymentModel paymentMoney =
      PaymentModel(name: S.current.lPayMoney, type: TypesPayment.money);

  loadPayment() async {
    inAsyncCall = true;

    _payments.clear();

    _payments.add(paymentCash);
    _payments.add(paymentMoney);

    setPaymentItems(payments);
    inAsyncCall = false;
    notifyListeners();
  }
}
