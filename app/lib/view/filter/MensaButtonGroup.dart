import 'package:app/view/filter/MensaButtonGroupEntry.dart';
import 'package:flutter/material.dart';

/// A button group that is used in the Mensa app.
class MensaButtonGroup<T> extends StatelessWidget {
  final T _value;
  final Function(T) _onChanged;
  final List<MensaButtonGroupEntry<T>> _entries;

  /// Creates a new MensaButtonGroup.
  const MensaButtonGroup(
      {super.key,
      required T value,
      required Function(T) onChanged,
      required List<MensaButtonGroupEntry<T>> entries})
      : _value = value,
        _onChanged = onChanged,
        _entries = entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: Theme.of(context).colorScheme.surfaceDim, width: 1)),
      child: IntrinsicHeight(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _entries
            .map((e) => e.build(context, e.value == _value, _onChanged))
            .toList(),
      )),
    );
  }
}
