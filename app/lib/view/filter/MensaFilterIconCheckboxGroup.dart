import 'package:app/view/filter/MensaFilterIconCheckbox.dart';
import 'package:flutter/cupertino.dart';

class MensaFilterIconCheckboxGroup<T> extends StatelessWidget {
  final List<MensaFilterIconCheckbox<T>> _items;
  final List<T> _selectedValues;
  final Function(List<T>) _onChanged;

  const MensaFilterIconCheckboxGroup(
      {super.key,
      required List<MensaFilterIconCheckbox<T>> items,
      required List<T> selectedValues,
      required Function(List<T>) onChanged})
      : _items = items,
        _selectedValues = selectedValues,
        _onChanged = onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
        runAlignment: WrapAlignment.center,
        //alignment: WrapAlignment.spaceEvenly,
        spacing: 8,
        runSpacing: 8,
        children: _items
            .map((e) => e.build(context, _selectedValues.contains(e.value), () {
                  if (_selectedValues.contains(e.value)) {
                    _selectedValues.remove(e.value);
                  } else {
                    _selectedValues.add(e.value);
                  }
                  _onChanged(_selectedValues);
                }))
            .toList());
  }
}
