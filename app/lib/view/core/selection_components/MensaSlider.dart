import 'package:flutter/material.dart';

class MensaSlider extends StatelessWidget {
  final void Function(double)? _onChanged;
  final double _value;
  final double _min;
  final double _max;
  final int? _divisions;

  const MensaSlider(
      {super.key, required onChanged, required value, min = 0.0, max = 1.0, divisions})
      : _onChanged = onChanged,
        _value = value,
        _min = min,
        _max = max,
        _divisions = divisions;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
        data: const SliderThemeData(trackHeight: 2),
        child: Slider(
          min: _min,
          max: _max,
          divisions: _divisions,
          value: _value,
          onChanged: _onChanged,
        ));
  }
}
