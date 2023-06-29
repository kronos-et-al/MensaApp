import 'package:flutter/material.dart';

/// A dropdown entry that is used in the Mensa app.
class MensaDropdownEntry<T> extends StatelessWidget {
  final T _value;
  final String _label;

  /// Creates a new MensaDropdownEntry.
  /// @param key The key to identify this widget.
  /// @param value The value of the entry.
  /// @param label The label of the entry.
  /// @returns A new MensaDropdownEntry.
  const MensaDropdownEntry({super.key, required value, required label})
      : _value = value,
        _label = label;

  /// Builds the widget.
  /// @param context The context in which the widget is built.
  /// @returns The widget.
  @override
  DropdownMenuItem<T> build(BuildContext context) {
    return DropdownMenuItem(value: _value, child: Text(_label));
  }
}
