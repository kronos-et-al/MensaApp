import 'package:flutter/material.dart';

class MensaFullscreenDialog extends StatelessWidget {
  final PreferredSizeWidget? _appBar;
  final Widget? _content;
  final Widget? _actions;

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
    return Scaffold(
        appBar: _appBar,
        body: _content ?? Container(),
        bottomNavigationBar: _actions ?? Container());
  }
}
