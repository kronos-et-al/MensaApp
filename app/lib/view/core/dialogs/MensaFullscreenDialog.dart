import 'package:flutter/material.dart';

/// This widget is used to display a fullscreen dialog.
class MensaFullscreenDialog extends StatelessWidget {
  final PreferredSizeWidget? _appBar;
  final Widget? _content;
  final Widget? _actions;

  /// Creates a new fullscreen dialog instance.
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Scaffold(
            appBar: _appBar,
            body: _content ?? Container(),
            bottomNavigationBar: _actions ?? Container()));
  }
}
