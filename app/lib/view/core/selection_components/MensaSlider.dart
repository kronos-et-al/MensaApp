import 'package:flutter/material.dart';

/// A slider that is used in the Mensa app and enables the user to select a value from a range.
class MensaSlider extends StatelessWidget {
  final void Function(double)? _onChanged;
  final double _value;
  final double _min;
  final double _max;
  final int? _divisions;
  final String? _label;

  /// Creates a new MensaSlider.
  const MensaSlider(
      {super.key,
      required Function(double)? onChanged,
      required double value,
      double min = 0.0,
      double max = 1.0,
      int? divisions,
      String? label})
      : _onChanged = onChanged,
        _value = value,
        _min = min,
        _max = max,
        _divisions = divisions,
        _label = label;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
        data: SliderThemeData(
          trackHeight: 2,
          showValueIndicator: ShowValueIndicator.always,
          inactiveTrackColor: Theme.of(context).colorScheme.surface,
        ),
        child: Slider(
          min: _min,
          max: _max,
          divisions: _divisions,
          label: _label,
          value: _value,
          onChanged: _onChanged,
        ));
  }
}
