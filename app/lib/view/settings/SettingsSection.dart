import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// This class represents a section in the settings.
class SettingsSection extends StatelessWidget {
  final String _heading;
  final List<Widget> _children;

  /// Creates a new SettingsSection.
  /// @param key The key to identify this widget.
  /// @param heading The heading of the section.
  /// @param children The children of the section.
  /// @returns A new SettingsSection.
  const SettingsSection({super.key, required heading, required children})
      : _heading = heading,
        _children = children;

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
        ..._children
      ],
    );
  }
}
