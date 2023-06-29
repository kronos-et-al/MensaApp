import 'package:flutter/material.dart';

class MensaToggle extends StatelessWidget {

  final void Function(bool)? _onChanged;
  final bool _value;
  final String _label;

  const MensaToggle({super.key, required onChanged, required value, required label}): _onChanged = onChanged, _value = value, _label = label;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(8), child: Row(
      children: [
        Switch(value: _value, onChanged: _onChanged),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            _onChanged!(!_value);
          },
          child: Text(_label, style: Theme.of(context).textTheme.labelLarge),
        ),
      ],
    ));
  }

}