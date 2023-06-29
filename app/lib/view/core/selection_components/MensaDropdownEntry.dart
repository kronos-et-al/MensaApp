import 'package:flutter/material.dart';

class MensaDropdownEntry<T> extends StatelessWidget {
  final T _value;
  final String _label;

  const MensaDropdownEntry({super.key, required value, required label})
      : _value = value,
        _label = label;

  @override
  DropdownMenuItem<T> build(BuildContext context) {
    return DropdownMenuItem(value: _value, child: Text(_label));
  }
}
