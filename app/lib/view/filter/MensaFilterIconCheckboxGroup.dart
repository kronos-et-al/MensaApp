import 'package:app/view/filter/MensaFilterIconCheckbox.dart';
import 'package:flutter/cupertino.dart';

/// This widget is used to display a group of MensaFilterIconCheckbox widgets.
class MensaFilterIconCheckboxGroup<T> extends StatelessWidget {
  final List<MensaFilterIconCheckbox<T>> _items;
  final List<T> _selectedValues;
  final Function(List<T>) _onChanged;

  /// Creates a MensaFilterIconCheckboxGroup widget.
  /// @param key The key to use for this widget.
  /// @param items The items to display.
  /// @param selectedValues The values that are currently selected.
  /// @param onChanged The function to call when the selection changes.
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
    double width = MediaQuery.of(context).size.width;
    return Wrap(
        runAlignment: WrapAlignment.center,
        spacing: ((width - ((width % 80) * 80)) / (width % 80 - 1) + 1)
            .floorToDouble(),
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
