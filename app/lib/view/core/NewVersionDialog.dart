import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/icons/mensa_icons.dart';

class NewVersionDialog extends StatelessWidget {
  final String version;
  final List<String> changes;

  const NewVersionDialog({
    super.key,
    required this.version,
    required this.changes,
  });

  static List<String> getChanges(BuildContext context, String version) {
    final baseVersion = version.split('+')[0];
    final versionKey = baseVersion.replaceAll('.', '_');

    final List<String> changes = [];

    for (int i = 0; i < 10; i++) {
      final key = "update.changes.$versionKey.$i";
      final translation = FlutterI18n.translate(context, key);
      if (translation != key) {
        changes.add(translation);
      } else {
        break;
      }
    }

    return changes;
  }

  List<InlineSpan> _parseInlineStyles(String text) {
    final List<InlineSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final Match match in boldRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              children: [
                const MensaIcon(
                  MensaIcons.logo,
                  size: 80,
                  useOriginalColor: true,
                ),
                const SizedBox(height: 16),
                Text(
                  "${FlutterI18n.translate(context, "update.title")} $version",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FlutterI18n.translate(context, "update.message"),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...changes.map(
                    (change) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: theme.colorScheme.onSurface,
                                ),
                                children: _parseInlineStyles(change),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: MensaButton(
                onPressed: () => Navigator.of(context).pop(),
                text: FlutterI18n.translate(context, "common.ok"),
                semanticLabel: FlutterI18n.translate(context, "common.ok"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
