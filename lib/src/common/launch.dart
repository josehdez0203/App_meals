import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:url_launcher/url_launcher.dart';

final _pref = PreferencesProvider();

openMapDirections(double lt, double lg) {
  launchUrl(
      Uri.parse('https://www.google.com/maps/dir//$lt,$lg/@$lt,$lg,17.82z/'),
      mode: LaunchMode.externalApplication);
}

call(String phone) {
  launchUrl(Uri.parse('tel:$phone'), mode: LaunchMode.externalApplication);
}

sendWhatsapp(String phone, String message) {
  launchUrl(
      Uri.parse(
          'https://api.whatsapp.com/send?phone=${phone.replaceAll('+', '')}&text=Hola soy ${_pref.user.fullName} de $kNameApp un pedido de: \n$message'),
      mode: LaunchMode.externalApplication);
}

goToUrl(String url) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
