import 'package:flutter/material.dart';

/// A button that is used in the Mensa app.
class MensaButton extends StatelessWidget {
  final void Function()? _onPressed;
  final void Function()? _onLongPressed;
  final String _text;

  /// Creates a new MensaButton.
  /// @param key The key to identify this widget.
  /// @param onPressed The function that is called when the button is pressed.
  /// @param onLongPressed The function that is called when the button is long pressed.
  /// @param text The text that is displayed on the button.
  /// @returns A new MensaButton.
  const MensaButton({super.key, required onPressed, onLongPressed, required text}): _onPressed = onPressed, _onLongPressed = onLongPressed, _text = text;

  /// Builds the widget.
  /// @param context The context in which the widget is built.
  /// @returns The widget.
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
