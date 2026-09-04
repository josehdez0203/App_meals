import 'package:flutter/material.dart';
import 'package:app_meals/constants/code_error_constant.dart';
import 'package:app_meals/src/provider/preferences_provider.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:app_meals/src/screens/deliveryman/petitions/widget/list_petitions.dart';
import 'package:app_meals/src/screens/welcome/welcome_screen.dart';
import 'package:app_meals/src/widgets/image_is_empty.dart';
import 'package:app_meals/src/widgets/modal_progress_hud.dart';
import 'package:table_calendar/table_calendar.dart';

class ContentPetitions extends StatefulWidget {
  const ContentPetitions({
    super.key,
    required this.petitionsController,
  }) ;

  final PetitionsController petitionsController;

  @override
  State<ContentPetitions> createState() => _ContentPetitionsState();
}

class _ContentPetitionsState extends State<ContentPetitions>
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
    final codeError = await widget.petitionsController.checkSession();

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
        widget.petitionsController.loadPetitions();
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
      inAsyncCall: widget.petitionsController.inAsyncCall,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.petitionsController.inAsyncCall,
            child: const LinearProgressIndicator(),
          ),
          Visibility(
            visible: widget.petitionsController.currentScreen == 1,
            child: TableCalendar(
              calendarFormat: CalendarFormat.week,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2069, 1, 1),
              focusedDay: widget.petitionsController.selectedDay,
              currentDay: widget.petitionsController.selectedDay,
              onDaySelected: (selectedDay, focusedDay) {
                widget.petitionsController.selectedDay = selectedDay;
              },
            ),
          ),
          widget.petitionsController.petitions.isEmpty
              ? const ImageIsEmpty('assets/screen/petitions.png')
              : Expanded(
                  child: ListPetitions(widget.petitionsController.petitions)),
        ],
      ),
    );
  }
}
