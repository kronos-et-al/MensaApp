import 'package:flutter/material.dart';

/// This widget is used to display a fullscreen dialog.
class MensaFullscreenDialog extends StatelessWidget {
  final PreferredSizeWidget? _appBar;
  final Widget? _content;
  final Widget? _actions;

  /// Creates a fullscreen dialog.
  /// @param key The key to use for this widget.
  /// @param appBar The app bar to display.
  /// @param content The content to display.
  /// @param actions The actions to display.
  /// @returns a widget that displays a fullscreen dialog
  const MensaFullscreenDialog(
      {super.key,
      PreferredSizeWidget? appBar,
      Widget? content,
      Widget? actions})
      : _appBar = appBar,
        _content = content,
        _actions = actions;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Scaffold(
            appBar: _appBar,
            body: _content ?? Container(),
            bottomNavigationBar: _actions ?? Container()));
  }
}
