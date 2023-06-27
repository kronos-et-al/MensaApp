import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:flutter/material.dart';

class MensaDropdown<T> extends StatelessWidget {
  final void Function(T?)? _onChanged;
  final T _value;
  final List<MensaDropdownEntry<T>> _items;

  const MensaDropdown(
      {super.key,
      required Function(T?)? onChanged,
      required T value,
      required List<MensaDropdownEntry<T>> items})
      : _onChanged = onChanged,
        _value = value,
        _items = items;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
              elevation: 0,
              borderRadius: BorderRadius.circular(4.0),
              value: _value,
              onChanged: _onChanged,
              items: _items.map((e) => e.build(context)).toList(),
            ))));
  }
}
