import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/about/about_screen.dart';
import 'package:app_meals/src/screens/addresses/addresses_screen.dart';
import 'package:app_meals/src/screens/admin/category/category_screen.dart';
import 'package:app_meals/src/screens/admin/credit/credit_screen.dart';
import 'package:app_meals/src/screens/manager/company/company_screen.dart';
import 'package:app_meals/src/screens/manager/enrollment/enrollment_screen.dart';
import 'package:app_meals/src/screens/notification/notification_screen.dart';
import 'package:app_meals/src/screens/profile/profile_screen.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_screen.dart';
import 'package:app_meals/src/screens/main/tab_main_screen.dart';
import 'package:app_meals/src/screens/manager/requests/requests_screen.dart';
import 'package:app_meals/src/widgets/avatar_image.dart';

class DraweMenu extends StatelessWidget {
  DraweMenu({super.key});

  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Header(pref),
                ),
                Visibility(
                  visible: pref.user.roles.contains(TypesRol.admin),
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: ListTile(
                        leading: const Icon(Icons.price_check_outlined,
                            color: kPrimaryColor),
                        title: Text(S.of(context).tTopUpBalance),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreditScreen()));
                        }),
                  ),
                ),
                Visibility(
                  visible: pref.user.roles.contains(TypesRol.admin),
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: ListTile(
                        leading: const Icon(Icons.category_outlined,
                            color: kPrimaryColor),
                        title: Text(S.of(context).tCategories),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CategoryScreen()));
                        }),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: ListTile(
                      leading: const Icon(Icons.notification_add_outlined,
                          color: kPrimaryColor),
                      title: Text(S.of(context).tNotifications),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificacionPage()));
                      }),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: ListTile(
                      leading: const Icon(Icons.store_outlined,
                          color: kPrimaryColor),
                      title: Text(S.of(context).tStores),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CompanyScreen()));
                      }),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: ListTile(
                      leading: const Icon(Icons.pin_drop_outlined,
                          color: kPrimaryColor),
                      title: Text(S.of(context).tAddresses),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddressesScreen()));
                      }),
                ),
                if (pref.user.roles.length > 1)
                  Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: ListTile(
                      leading: const Icon(Icons.switch_account_outlined,
                          color: kPrimaryColor),
                      title: Text(S.of(context).tChangeRole),
                      onTap: () {
                        // El Navigator se captura ANTES de cerrar el drawer: al
                        // terminar su animacion de cierre el contexto del menu
                        // queda desmontado, y cualquier Navigator.of(context)
                        // posterior se cancelaria en silencio.
                        final navigator = Navigator.of(context);
                        Navigator.pop(context);
                        _showRoleSelector(navigator);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        Footer(pref)
      ],
    ));
  }

  Future<void> _showRoleSelector(NavigatorState navigator) async {
    final role = await showModalBottomSheet<String>(
      // Se usa el contexto del Navigator (siempre montado) en lugar del del
      // drawer, que ya no existe cuando el usuario elige.
      context: navigator.context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: pref.user.roles
              .map(
                (role) => ListTile(
                  leading: Icon(_roleIcon(role), color: kPrimaryColor),
                  title: Text(_roleLabel(context, role)),
                  onTap: () => Navigator.pop(context, role),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (role == null) return;
    pref.activeRole = role;
    // pushAndRemoveUntil reemplaza la pantalla actual por la del rol elegido.
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _screenForRole(role)),
      (_) => false,
    );
  }

  Widget _screenForRole(String role) {
    if (role == TypesRol.deliveryman) return const PetitionsScreen();
    if (role == TypesRol.manager) return const RequestsScreen();
    return const TabMainScreen();
  }

  String _roleLabel(BuildContext context, String role) {
    if (role == TypesRol.client) return S.of(context).lClient;
    if (role == TypesRol.deliveryman) return S.of(context).lDeliveryman;
    if (role == TypesRol.manager) return S.of(context).lManager;
    return role;
  }

  IconData _roleIcon(String role) {
    if (role == TypesRol.deliveryman) return Icons.delivery_dining;
    if (role == TypesRol.manager) return Icons.storefront_outlined;
    return Icons.person_outline;
  }
}

class Header extends StatelessWidget {
  final PreferencesProvider pref;

  const Header(
    this.pref, {
    super.key,
  }) ;

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularPercentIndicator(
          radius: 33.0,
          lineWidth: 3.0,
          percent: 1.0,
          center: AvatarImage(
              width: 60,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              image: pref.user.image),
          progressColor: kPrimaryColor,
        ),
        const SizedBox(width: kDefaultPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                child: Text(pref.user.fullName,
                    textScaler: const TextScaler.linear(1.4), overflow: TextOverflow.visible)),
            SizedBox(
                child: Text(pref.user.email,
                    textScaler: const TextScaler.linear(0.9),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(color: kSecondaryColor))),
          ],
        )
      ],
    );
    return Stack(
      children: [
        content,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blueAccent.withValues(alpha: (0.6 * 255)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
            ),
          ),
        ),
      ],
    );
  }
}

class Footer extends StatelessWidget {
  const Footer(
    this.pref, {
    super.key,
  }) ;

  final PreferencesProvider pref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible:
              !pref.user.roles.contains(TypesRol.deliveryman) && !pref.isGuest,
          child: ListTile(
            leading: const Icon(Icons.app_registration_outlined,
                color: kPrimaryColor),
            title: Text(S.of(context).tRegisterStore),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EnrollmentScreen()));
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.mode_of_travel, color: kPrimaryColor),
          title: Text(S.of(context).tAbout),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AboutScreen()));
          },
        ),
        const Divider(),
        const SizedBox(height: 1),
        const Text(
          'By using our service you agree to our Terms & Privacy Policy\nV: $kVersionn\nPowered by Planck',
          textScaler: TextScaler.linear(0.72),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
