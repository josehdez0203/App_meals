import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_meals/constants/constants.dart';
import 'package:app_meals/constants/types_constant.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/common/status_label.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/services/auth_service.dart';

class PushProvider {
  static PushProvider? _instance;

  PushProvider._internal();

  factory PushProvider() {
    _instance ??= PushProvider._internal();
    return _instance!;
  }

  final prefs = PreferencesProvider();
  final AuthService _authService = AuthService();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
          '${kNameApp}_CHANNEL_PLANCK', '$kNameApp NOTIFICATIONS PLANCK',
          groupKey: '$kNameApp-NOTIFICATIONS-PLANCK',
          playSound: true,
          autoCancel: true,
          importance: Importance.max,
          priority: Priority.high);

  final StreamController<Map<String, dynamic>> _notificationsStream =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notifications => _notificationsStream.stream;

  getToken() async {
    _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    await _firebaseMessaging.requestPermission(
        alert: true, sound: true, badge: true);
    _firebaseMessaging.getToken().then((tokenPush) {
      if (tokenPush != null) {
        prefs.tokenPush = tokenPush;
        if (prefs.isAuth) _authService.updateTokenPush(tokenPush);
      }
    }).catchError((error) {});
  }

  Future showNotification(RemoteNotification push) async {
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    _localNotifications.show(
        1682, push.title, push.body, platformChannelSpecifics);
  }

  cancelAll() {
    _localNotifications.cancelAll();
  }

  init() async {
    await shouldShowRequestPermissionRationale();
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _localNotifications.initialize(initializationSettings);
    getToken();
  }

  shouldShowRequestPermissionRationale() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
  }

  Future _onMessageHandler(RemoteMessage message) async {
    if (!message.data.containsKey('type')) return;
    _notificationsStream.add(message.data);
    checkMessage(message);
  }

  checkMessage(RemoteMessage message) {
    String? title, body;
    if (message.data.containsKey('title') && message.data.containsKey('body')) {
      title = message.data['title'];
      body = message.data['body'];
    } else if (message.data['type'] == TypesNotification.changeOrderStatust) {
      title = kNameApp;
      body = statusOrderLabel(int.parse(message.data['status']),
          int.parse(message.data['companyType']));
    }
    if (title == null || body == null) return;

    PushProvider()
        .showNotification(RemoteNotification(title: title, body: body));
  }

  dispose() {
    _notificationsStream.close();
  }
}

@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await PreferencesProvider().init();
  await S.load(Locale(PreferencesProvider().locale));
  if (!message.data.containsKey('type')) return;
  PushProvider().checkMessage(message);
}
