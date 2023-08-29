import 'package:flutter/material.dart';

/// A button that is used as cta in the Mensa app.
class MensaCtaButton extends StatelessWidget {
  final void Function()? _onPressed;
  final void Function()? _onLongPressed;
  final String _text;
  final String _semanticLabel;

  /// Creates a new MensaCtaButton.
  /// The String [text] is displayed on the button.
  const MensaCtaButton(
      {super.key,
      required onPressed,
      onLongPressed,
      required text,
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
        child: MaterialButton(
          textColor: Theme.of(context).colorScheme.onPrimary,
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0,
          highlightElevation: 0,
          onPressed: _onPressed,
          onLongPress: _onLongPressed,
          child: Text(_text,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ));
  }
}
