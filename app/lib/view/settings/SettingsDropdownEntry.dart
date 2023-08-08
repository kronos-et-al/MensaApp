import 'package:app/view/core/selection_components/MensaDropdown.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// A dropdown with heading that is used in the settings of the mensa app.
class SettingsDropdownEntry<T> extends StatelessWidget {
  final void Function(T?)? _onChanged;
  final T _value;
  final List<MensaDropdownEntry<T>> _items;
  final String _heading;

  /// Creates a new MensaDropdown with heading.
  const SettingsDropdownEntry(
      {super.key,
      required Function(T?)? onChanged,
      required T value,
      required List<MensaDropdownEntry<T>> items,
      required String heading})
      : _onChanged = onChanged,
        _value = value,
        _items = items,
        _heading = heading;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FlutterI18n.translate(context, _heading),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: MensaDropdown<T>(
                backgroundColor: Theme.of(context).colorScheme.surface,
                onChanged: _onChanged,
                value: _value,
                items: _items),
          )
        ])
      ],
    );
  }
}
