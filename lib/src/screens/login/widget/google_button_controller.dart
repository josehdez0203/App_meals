import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_meals/src/models/user_model.dart';
import 'package:app_meals/src/provider/db_provider.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/services/auth_service.dart';

class GoogleButtonController extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthService authService = AuthService();
  final prefs = PreferencesProvider();

  GoogleSignIn get googleSignIn => _googleSignIn;

  Future<UserModel?> sigInGoogle() async {
    try {
      if (await googleSignIn.isSignedIn()) await googleSignIn.disconnect();
      await googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    if (googleSignIn.currentUser == null) {
      return null;
    }

    final String idGoogle = googleSignIn.currentUser!.id;
    final String fullName = googleSignIn.currentUser!.displayName.toString();
    final String email = googleSignIn.currentUser!.email;
    final String image = googleSignIn.currentUser!.photoUrl.toString();

    Map<String, dynamic>? decodedResp =
        await authService.google(idGoogle, fullName, email, image);

    if (decodedResp == null) {
      return null;
    }
    if (decodedResp.containsKey('user')) {
      UserModel user = UserModel.fromJson(decodedResp['user']);
      if (user.addresses.isNotEmpty) {
        await DBProvider.db.createAddress(user.addresses.first);
      }
      prefs.user = user;
      prefs.token = user.token;
      return user;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return null;
  }
}
