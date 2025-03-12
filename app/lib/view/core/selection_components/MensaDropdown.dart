import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:flutter/material.dart';

/// A dropdown that is used in the Mensa app.
class MensaDropdown<T> extends StatelessWidget {
  final void Function(T?)? _onChanged;
  final T _value;
  final List<MensaDropdownEntry<T>> _items;
  final Color? _backgroundColor;

  /// Creates a new MensaDropdown.
  const MensaDropdown(
      {super.key,
      required Function(T?)? onChanged,
      required T value,
      required List<MensaDropdownEntry<T>> items,
      Color? backgroundColor})
      : _onChanged = onChanged,
        _value = value,
        _items = items,
        _backgroundColor = backgroundColor;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Container(
        // Container is used to give the dropdown a background color.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: _backgroundColor ?? Theme.of(context).colorScheme.surfaceDim,
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonHideUnderline(
                // DropdownButtonHideUnderline is used to hide the underline of the dropdown.
                child: DropdownButton<T>(
              dropdownColor: Theme.of(context).colorScheme.surfaceDim,
              elevation: 0,
              borderRadius: BorderRadius.circular(4.0),
              value: _value,
              onChanged: _onChanged,
              items: _items.map((e) => e.build(context)).toList(),
            ))));
  }
}
