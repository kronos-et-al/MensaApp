import 'package:flutter/material.dart';

/// A input component that is used in the Mensa app and enables the user to enter a 1-5 star rating.
class MensaRatingInput extends StatelessWidget {
  final Function(int) _onChanged;
  final int _value;
  final int _max;
  final Color? _color;
  final bool _disabled;

  /// Creates a new MensaRatingInput.
  /// @param key The key to identify this widget.
  /// @param onChanged The function that is called when the rating is changed.
  /// @param value The current rating.
  /// @param max The maximum rating.
  /// @param color The color of the stars.
  /// @param disabled Whether the input is disabled.
  /// @returns A new MensaRatingInput.
  const MensaRatingInput(
      {super.key,
      required Function(int) onChanged,
      required int value,
      int max = 5,
      Color? color,
      bool disabled = false})
      : _onChanged = onChanged,
        _value = value,
        _max = max,
        _color = color,
        _disabled = disabled;

  /// Builds the widget.
  /// @param context The context in which the widget is built.
  /// @returns The widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _max; i++)
          AbsorbPointer(
              absorbing: _disabled,
              child: IconButton(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => {if (!_disabled) _onChanged(i + 1)},
                icon: Icon(
                  i < _value ? Icons.star : Icons.star_border,
                  color: _color ?? Theme.of(context).colorScheme.primary,
                ),
              ))
      ],
    );
  }
}
