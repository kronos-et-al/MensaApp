import 'package:app/view/core/buttons/MensaTapable.dart';
import 'package:app/view/core/icons/navigation/NavigationArrowLeftIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationArrowRightIcon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealPlanDateSelect extends StatelessWidget {
  final DateTime _date;
  final Function(DateTime) _onDateChanged;

  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  MealPlanDateSelect(
      {super.key,
      required DateTime date,
      required Function(DateTime) onDateChanged})
      : _date = date,
        _onDateChanged = onDateChanged;

  @override
  Widget build(BuildContext context) {
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
              _dateFormat.format(_date),
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
                ).then((value) => _onDateChanged(value!))
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
