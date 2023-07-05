import 'package:flutter/material.dart';

/// A slider that is used in the Mensa app and enables the user to select a value from a range.
class MensaSlider extends StatelessWidget {
  final void Function(double)? _onChanged;
  final double _value;
  final double _min;
  final double _max;
  final int? _divisions;

  /// Creates a new MensaSlider.
  /// @param key The key to identify this widget.
  /// @param onChanged The function that is called when the value is changed.
  /// @param value The current value.
  /// @param min The minimum value.
  /// @param max The maximum value.
  /// @param divisions The number of discrete divisions.
  /// @returns A new MensaSlider.
  const MensaSlider(
      {super.key,
      required onChanged,
      required value,
      min = 0.0,
      max = 1.0,
      divisions})
      : _onChanged = onChanged,
        _value = value,
        _min = min,
        _max = max,
        _divisions = divisions;

  /// Builds the widget.
  /// @param context The context in which the widget is built.
  /// @returns The widget.
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
        data: SliderThemeData(
          trackHeight: 2,
          inactiveTrackColor: Theme.of(context).colorScheme.surface,
        ),
        child: Slider(
          min: _min,
          max: _max,
          divisions: _divisions,
          value: _value,
          onChanged: _onChanged,
        ));
  }
}
