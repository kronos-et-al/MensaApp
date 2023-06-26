import 'package:flutter/material.dart';

class MensaCheckbox extends StatelessWidget {
  final void Function(bool?)? _onChanged;
  final bool _value;
  final String _label;

  const MensaCheckbox(
      {super.key, required onChanged, required value, required label})
      : _onChanged = onChanged,
        _value = value,
        _label = label;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(8), child: Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.surface,
              width: 1,
            ),
          ),
          child: Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary;
              } else {
                return Theme.of(context).colorScheme.surface;
              }
            }),
            checkColor: Theme.of(context).colorScheme.onPrimary,
            value: _value,
            onChanged: _onChanged,
          ),
        ),
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
