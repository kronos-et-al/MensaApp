import 'package:flutter/material.dart';

/// A button that is used in the Mensa app.
class MensaButton extends StatelessWidget {
  final void Function()? _onPressed;
  final void Function()? _onLongPressed;
  final String _text;

  /// Creates a new MensaButton.
  /// The String [text] is displayed on the button.
  const MensaButton(
      {super.key, required onPressed, onLongPressed, required text})
      : _onPressed = onPressed,
        _onLongPressed = onLongPressed,
        _text = text;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      textColor: Theme.of(context).colorScheme.onSurface,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 0,
      highlightElevation: 0,
      onPressed: _onPressed,
      onLongPress: _onLongPressed,
      child: Text(_text),
    );
  }
}
