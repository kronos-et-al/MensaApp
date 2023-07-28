import 'package:app/view/core/buttons/MensaTapable.dart';
import 'package:app/view/core/icons/navigation/NavigationArrowLeftIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationArrowRightIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

class MealPlanDateSelect extends StatelessWidget {
  final DateTime _date;
  final Function(DateTime) _onDateChanged;

  MealPlanDateSelect(
      {super.key,
      required DateTime date,
      required Function(DateTime) onDateChanged})
      : _date = date,
        _onDateChanged = onDateChanged;

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E dd.MM.yyyy', FlutterI18n.currentLocale(context)?.languageCode);
    return Row(children: [
      MensaTapable(
        child: const Padding(
            padding: EdgeInsets.all(8), child: NavigationArrowLeftIcon()),
        onTap: () {
          DateTime before = _date.subtract(const Duration(days: 1));
          _onDateChanged(before.isBefore(DateTime(1923)) ? _date : before);
        },
      ),
      MensaTapable(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              dateFormat.format(_date),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () => {
                showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(1923),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                ).then((value) => _onDateChanged(value ?? DateTime.now()))
              }),
      MensaTapable(
        child: const Padding(
            padding: EdgeInsets.all(8), child: NavigationArrowRightIcon()),
        onTap: () {
          DateTime after = _date.add(const Duration(days: 1));
          _onDateChanged(
              after.isAfter(DateTime.now().add(const Duration(days: 365 * 10)))
                  ? _date
                  : after);
        },
      ),
    ]);
  }
}
