import 'package:flutter/material.dart';

/// A icon button that is used in the Mensa app.
class MensaIconButton extends StatelessWidget {
  final void Function() _onPressed;
  final Widget _icon;
  final String _semanticLabel;

  /// Creates a new MensaIconButton.
  /// The String [text] is displayed on the button.
  const MensaIconButton(
      {super.key,
      required void Function() onPressed,
      required Widget icon,
      required String semanticLabel})
      : _onPressed = onPressed,
        _icon = icon,
        _semanticLabel = semanticLabel;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Semantics(
        button: true,
        label: _semanticLabel,
        child: IconButton(
            onPressed: _onPressed,
            icon: _icon,
            padding: const EdgeInsets.all(12)));
  }
}
