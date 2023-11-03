import 'package:flutter/material.dart';

/// A button that is used in the Mensa app.
class MensaButton extends StatelessWidget {
  final void Function()? _onPressed;
  final void Function()? _onLongPressed;
  final String _text;
  final String _semanticLabel;
  final bool _loading;
  final bool _disabled;

  /// Creates a new MensaButton.
  /// The String [text] is displayed on the button.
  const MensaButton(
      {super.key,
      required onPressed,
      onLongPressed,
      required text,
      required String semanticLabel,
      bool loading = false,
      bool disabled = false})
      : _onPressed = onPressed,
        _onLongPressed = onLongPressed,
        _text = text,
        _semanticLabel = semanticLabel,
        _loading = loading,
        _disabled = disabled;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Semantics(
        button: true,
        label: _semanticLabel,
        child: MaterialButton(
            textColor: Theme.of(context).colorScheme.onSurface,
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            elevation: 0,
            highlightElevation: 0,
            onPressed: _disabled ? null : _onPressed,
            onLongPress: _onLongPressed,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  _text,
                  style: TextStyle(
                      color: _loading
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.onSurface),
                ),
                if (_loading)
                  SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface))
              ],
            )));
  }
}
