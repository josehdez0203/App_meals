import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/manager/requests/requests_controller.dart';
import 'package:app_meals/src/screens/manager/requests/widget/list_requests.dart';
import 'package:app_meals/src/screens/welcome/welcome_screen.dart';
import 'package:app_meals/src/widgets/image_is_empty.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:table_calendar/table_calendar.dart';

class ContentRequests extends StatefulWidget {
  const ContentRequests({
    super.key,
    required this.requestsController,
  }) ;

  final RequestsController requestsController;

  @override
  State<ContentRequests> createState() => _ContentRequestsState();
}

class _ContentRequestsState extends State<ContentRequests>
    with WidgetsBindingObserver {
  final pref = PreferencesProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => validateSession());
  }

  validateSession() async {
    final navigator = Navigator.of(context);
    final codeError = await widget.requestsController.checkSession();
    if (codeError == CodeError.unauthorized && !pref.isGuest) {
      PreferencesProvider().clean();
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (Route<dynamic> route) {
        return false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        widget.requestsController.loadRequests();
        validateSession();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: widget.requestsController.inAsyncCall,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.requestsController.inAsyncCall,
            child: const LinearProgressIndicator(),
          ),
          Visibility(
            visible: widget.requestsController.currentScreen == 1,
            child: TableCalendar(
              calendarFormat: CalendarFormat.week,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2069, 1, 1),
              focusedDay: widget.requestsController.selectedDay,
              currentDay: widget.requestsController.selectedDay,
              onDaySelected: (selectedDay, focusedDay) {
                widget.requestsController.selectedDay = selectedDay;
              },
            ),
          ),
          widget.requestsController.requests.isEmpty
              ? const ImageIsEmpty('assets/screen/requests.png')
              : Expanded(
                  child: ListRequests(widget.requestsController.requests)),
        ],
      ),
    );
  }
}
