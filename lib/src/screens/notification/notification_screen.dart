import 'package:flutter/material.dart';
import 'package:app_meals/generated/l10n.dart';
import 'package:app_meals/src/models/notification_model.dart';
import 'package:app_meals/src/screens/notification/widget/list_notifications.dart';

class NotificacionPage extends StatefulWidget {
  const NotificacionPage({super.key}) ;

  @override
  createState() => _NotificacionPageState();
}

class _NotificacionPageState extends State<NotificacionPage> {
  final List<NotificationModel> notifications = [];

  @override
  void initState() {
    notifications.add(NotificationModel(
      detail: 'APP de DELIVERY',
      hint:
          'App PROBADA [ Inglés-español | Null-safe | Provider | Rest API | Sockets | Cloud | Ca',
      image:
          'https://firebasestorage.googleapis.com/v0/b/curiosity-0001.appspot.com/o/nt%2Flili.jpeg?alt=media',
      url: 'https://udemy.planck.biz/lili',
    ));

    notifications.add(NotificationModel(
      detail: 'Acepta PAGOS con CRIPTOMONEDAS',
      hint:
          'Solana Pay | Frontend en Flutter | Backend en',
      image:
          'https://firebasestorage.googleapis.com/v0/b/curiosity-0001.appspot.com/o/nt%2Fpay.jpeg?alt=media',
      url: 'https://udemy.planck.biz/pay',
    ));

    notifications.add(NotificationModel(
      detail: 'VueJS y Smart Contract',
      hint:
          'Tu DApp con Vue 3 en la blockchain de Solana | GANA PROPINAS en el token SOL | Vu',
      image:
          'https://firebasestorage.googleapis.com/v0/b/curiosity-0001.appspot.com/o/nt%2Fjuno.jpeg?alt=media',
      url: 'https://udemy.planck.biz/vuejs-smart',
    ));

    notifications.add(NotificationModel(
      detail: 'ChatBot WhatsApp',
      hint:
          'Frontend en Flutter | Backend en NodeJS | Base de datos en MySQL | RESTfull |  Arc',
      image:
          'https://firebasestorage.googleapis.com/v0/b/curiosity-0001.appspot.com/o/nt%2Fcheck.jpeg?alt=media',
      url: 'https://udemy.planck.biz/whatsapp',
    ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(centerTitle: true, title: Text(S.of(context).tNotifications)),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10.0),
            Expanded(child: ListNotifications(notifications)),
          ],
        ),
      ),
    );
  }
}
