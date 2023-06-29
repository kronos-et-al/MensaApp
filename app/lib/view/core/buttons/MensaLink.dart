import 'package:flutter/material.dart';

class MensaLink extends StatelessWidget {
  final void Function()? _onPressed;
  final void Function()? _onLongPressed;
  final String _text;

  const MensaLink({super.key, required onPressed, onLongPressed, required text}): _onPressed = onPressed, _onLongPressed = onLongPressed, _text = text;

  @override
  Widget build(BuildContext context) {
    return (OutlinedButton(
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
