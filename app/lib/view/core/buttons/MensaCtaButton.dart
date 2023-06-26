import 'package:flutter/material.dart';

class MensaCtaButton extends StatelessWidget {
  final void Function()? _onPressed;
  final void Function()? _onLongPressed;
  final String _text;

  const MensaCtaButton({super.key, required onPressed, onLongPressed, required text}): _onPressed = onPressed, _onLongPressed = onLongPressed, _text = text;

  @override
  Widget build(BuildContext context) {
    return (MaterialButton(
      textColor: Theme.of(context).colorScheme.onPrimary,
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 0,
      highlightElevation: 0,
      onPressed: _onPressed,
      onLongPress: _onLongPressed,
      child: Text(_text),
    ));
  }
}
