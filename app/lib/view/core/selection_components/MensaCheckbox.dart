import 'package:flutter/material.dart';

/// A checkbox that is used in the Mensa app.
class MensaCheckbox extends StatelessWidget {
  final void Function(bool?)? _onChanged;
  final bool _value;
  final String _label;

  /// Creates a new MensaCheckbox.
  const MensaCheckbox(
      {super.key, required onChanged, required value, required label})
      : _onChanged = onChanged,
        _value = value,
        _label = label;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Container is used to give the checkbox a filled background
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceDim,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  width: 1,
                ),
              ),
              child: Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                // Set the border color of the checkbox to the primary color when it is selected and to the surface color when it is not selected, this makes the border invisible
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.primary;
                  } else {
                    return Theme.of(context).colorScheme.surfaceDim;
                  }
                }),
                checkColor: Theme.of(context).colorScheme.onPrimary,
                value: _value,
                onChanged: _onChanged,
              ),
            ),
            const SizedBox(width: 8),
            // GestureDetector is used to make the label clickable
            GestureDetector(
              onTap: () {
                _onChanged!(!_value);
              },
              child:
                  Text(_label, style: Theme.of(context).textTheme.labelLarge),
            ),
          ],
        ));
  }
}
