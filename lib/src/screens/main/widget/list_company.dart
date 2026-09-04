import 'package:flutter/material.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/company_model.dart';
import 'package:app_meals/src/screens/store/store_controller.dart';
import 'package:app_meals/src/screens/store/store_screen.dart';
import 'package:app_meals/src/screens/taxi/taxi_screen.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';
import 'package:app_meals/src/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class ListCompany extends StatelessWidget {
  final List<CompanyModel> companies;

  const ListCompany(this.companies, {super.key}) ;

  @override
  Widget build(BuildContext context) {
    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210),
      children: List.generate(
        companies.length,
        (index) {
          return _Company(companies[index]);
        },
      ),
    );
  }
}

class _Company extends StatelessWidget {
  final CompanyModel company;

  const _Company(this.company);

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _card(BuildContext context) {
    final card = Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: _cardBody(),
    );
    return Stack(
      children: <Widget>[
        card,
        company.isOpen ? Container() : _closedLabel(context),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withValues(alpha: (0.6 * 255)),
                onTap: () async {
                  final storeController =
                      Provider.of<StoreController>(context, listen: false);
                  storeController.company = company;
                  if (company.isOpen) {
                    if (company.type == TypesCompany.store) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StoreScreen(company)));
                    } else if (company.type == TypesCompany.taxi) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TaxiScreen(company)));
                    }
                  } else {
                    final s = S.of(context);
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => ConfirmationDialog(s.mDStoreClosed,
                          iconOk: const Icon(Icons.remove_red_eye_outlined),
                          labelOk: s.bAccept, onPressedOk: () async {
                        if (company.type == TypesCompany.store) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StoreScreen(company)));
                        } else if (company.type == TypesCompany.taxi) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TaxiScreen(company)));
                        }
                      }),
                    );
                  }
                }),
          ),
        ),
      ],
    );
  }

  Widget _cardBody() {
    return Column(
      children: <Widget>[
        AvatarImage(image: company.image),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Center(
                child: Text(
              company.name,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12.0),
              textAlign: TextAlign.center,
            )),
          ),
        ),
      ],
    );
  }

  Widget _closedLabel(BuildContext context) {
    return Positioned(
      top: 10.0,
      left: -55,
      child: Transform.rotate(
        alignment: FractionalOffset.center,
        angle: 345.0,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: (0.8 * 255)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(S.of(context).lClosed,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
