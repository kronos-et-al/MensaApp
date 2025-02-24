import 'package:app/view/core/icons/allergens/IAllergenIcon.dart';
import 'package:flutter/material.dart';

/// This widget is used to display a selectable icon with a text.
class MensaFilterIconCheckbox<T> {
  final IAllergenIcon _icon;
  final String _text;
  final T value;

  /// Creates a MensaFilterIconCheckbox widget.
  const MensaFilterIconCheckbox(
      {required IAllergenIcon icon, required String text, required this.value})
      : _icon = icon,
        _text = text;

  Widget build(BuildContext context, bool active, Function() onTap) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
            width: 2,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceDim),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Material(
          borderRadius: BorderRadius.circular(4.0),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(4.0),
            onTap: onTap,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  _icon,
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: Text(
                              _text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 8),
                            )))
                  ]),
                ]),
          )),
    );
  }
}
