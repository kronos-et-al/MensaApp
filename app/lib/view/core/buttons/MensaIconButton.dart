import 'package:flutter/material.dart';

/// A icon button that is used in the Mensa app.
class MensaIconButton extends StatelessWidget {
  final void Function() _onPressed;
  final Widget _icon;

  /// Creates a new MensaIconButton.
  /// @param key The key to identify this widget.
  /// @param onPressed The function that is called when the button is pressed.
  /// @param icon The icon that is displayed on the button.
  /// @returns A new MensaIconButton.
  const MensaIconButton(
      {super.key, required void Function() onPressed, required Widget icon})
      : _onPressed = onPressed,
        _icon = icon;

  /// Builds the widget.
  /// @param context The context in which the widget is built.
  /// @returns The widget.
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: _onPressed, icon: _icon);
  }
}
