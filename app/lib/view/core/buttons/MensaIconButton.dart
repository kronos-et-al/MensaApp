import 'package:flutter/material.dart';

class MensaIconButton extends StatelessWidget {
  final void Function() _onPressed;
  final Icon _icon;

  const MensaIconButton(
      {super.key, required void Function() onPressed, required Icon icon})
      : _onPressed = onPressed,
        _icon = icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: _onPressed, icon: _icon);
  }
}
