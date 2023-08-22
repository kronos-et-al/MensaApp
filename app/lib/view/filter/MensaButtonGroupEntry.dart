import 'package:flutter/material.dart';

/// This class represents a single entry in a MensaButtonGroup.
class MensaButtonGroupEntry<T> {
  final String _title;

  /// The value of the entry.
  final T value;

  /// Creates a new MensaButtonGroupEntry.
  const MensaButtonGroupEntry({required String title, required this.value})
      : _title = title;

  /// Builds the widget.
  Widget build(
      BuildContext context, bool selected, void Function(T) onChanged) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                color: selected ? Theme.of(context).colorScheme.primary : null,
                elevation: 0,
                onPressed: () => onChanged(value),
                child: Text(_title))));
  }
}
