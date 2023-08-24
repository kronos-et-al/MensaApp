import 'package:flutter/material.dart';

/// A button that is used as link in the Mensa app.
class MensaLink extends StatelessWidget {
  final void Function()? _onPressed;
  final void Function()? _onLongPressed;
  final String _text;
  final String _semanticLabel;

  /// Creates a new MensaLink.
  /// The String [text] is displayed on the button.
  const MensaLink(
      {super.key,
      required onPressed,
      onLongPressed,
      required String text,
      required String semanticLabel})
      : _onPressed = onPressed,
        _onLongPressed = onLongPressed,
        _text = text,
        _semanticLabel = semanticLabel;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Semantics(
        button: true,
        label: _semanticLabel,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            elevation: 0,
            side: BorderSide(
              color: Theme.of(context).colorScheme.surface,
              width: 1,
            ),
          ),
          onPressed: _onPressed,
          onLongPress: _onLongPressed,
          child: Text(_text),
        ));
  }
}
