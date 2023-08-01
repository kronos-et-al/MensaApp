import 'package:flutter/material.dart';

/// A toggle that is used in the Mensa app.
class MensaToggle extends StatelessWidget {
  final void Function(bool)? _onChanged;
  final bool _value;
  final String _label;

  /// Creates a new MensaToggle.
  const MensaToggle(
      {super.key, required onChanged, required value, required label})
      : _onChanged = onChanged,
        _value = value,
        _label = label;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              _onChanged!(!_value);
            },
            child: Text(_label, style: const TextStyle(fontSize: 16))),
        const Spacer(),
        Switch(value: _value, onChanged: _onChanged),
      ],
    );
  }
}
