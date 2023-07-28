import 'package:flutter/material.dart';

/// A text field that is used in the Mensa app.
class MensaTextField extends StatelessWidget {
  final TextEditingController _controller;

  /// Creates a new MensaTextField.
  /// @param key The key to identify this widget.
  /// @param controller The controller that is used to control the text field.
  /// @returns A new MensaTextField.
  const MensaTextField({super.key, required TextEditingController controller})
      : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ));
  }
}
