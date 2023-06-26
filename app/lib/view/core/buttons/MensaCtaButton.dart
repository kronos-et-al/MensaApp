import 'package:flutter/material.dart';

class MensaCtaButton extends StatelessWidget {
  void Function() onPressed;
  String text;

  MensaCtaButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return (MaterialButton(
      onPressed: onPressed,
      textColor: Theme.of(context).colorScheme.onPrimary,
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 0,
      child: Text(text),
    ));
  }
}
