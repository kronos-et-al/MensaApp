import 'package:flutter/material.dart';

/// A dropdown entry that is used in the Mensa app.
class MensaDropdownEntry<T> extends StatelessWidget {
  final T _value;
  final String _label;

  /// Creates a new MensaDropdownEntry.
  const MensaDropdownEntry({super.key, required value, required label})
      : _value = value,
        _label = label;

  /// Builds the widget.
  @override
  DropdownMenuItem<T> build(BuildContext context) {
    return DropdownMenuItem(value: _value, child: Text(_label));
  }
}
