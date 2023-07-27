import 'package:flutter/material.dart';

/// A toggle that is used in the Mensa app.
class MensaToggle extends StatelessWidget {
  final void Function(bool)? _onChanged;
  final bool _value;
  final String _label;

  /// Creates a new MensaToggle.
  /// @param key The key to identify this widget.
  /// @param onChanged The function that is called when the value is changed.
  /// @param value The current value.
  /// @param label The label of the toggle.
  /// @returns A new MensaToggle.
  const MensaToggle(
      {super.key, required onChanged, required value, required label})
      : _onChanged = onChanged,
        _value = value,
        _label = label;

  /// Builds the widget.
  /// @param context The context in which the widget is built.
  /// @returns The widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              _onChanged!(!_value);
            },
            child: Text(_label,
                style: TextStyle(fontSize: 16))),
        Spacer(),
        Switch(value: _value, onChanged: _onChanged),
      ],
    );
  }
}
