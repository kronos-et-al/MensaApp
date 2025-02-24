import 'package:flutter/material.dart';

/// This class is used to display the nutrients of a meal.
class MealNutrientsItem extends StatelessWidget {
  final String _name;
  final int _value;
  final String _unit;
  final bool _even;
  final bool _indent;

  /// Creates a MealNutrientsItem widget.
  const MealNutrientsItem({super.key, required String name, required int value, required String unit, bool even = false, bool indent = false})
      : _name = name, _value = value, _unit = unit, _even = even, _indent = indent;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Ink(decoration: BoxDecoration(
      color: _even ? theme.brightness == Brightness.dark ?  theme.colorScheme.surfaceDim : theme.colorScheme.surface : Colors.transparent
    ), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_indent) const SizedBox(width: 12),
        Text(_name, style: TextStyle(fontWeight: _indent ? FontWeight.w300 : FontWeight.w400)),
        Expanded(child: Container()),
        Text("$_value $_unit", style: const TextStyle(fontWeight: FontWeight.w100))
      ],
    )));
  }
}
