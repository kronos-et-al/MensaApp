import 'package:flutter/material.dart';

class MensaRatingInput extends StatelessWidget {
  final Function(int) _onChanged;
  final int _value;
  final int _max;
  final Color? _color;
  final bool _disabled;

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
