import 'package:flutter/material.dart';

class MensaFullscreenDialog {
  static void show(
      {required BuildContext context,
      PreferredSizeWidget? appBar,
      Widget? content,
      Widget? actions}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
            backgroundColor: Theme.of(context).colorScheme.background,
            child: SafeArea(
              child: Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  appBar: appBar,
                  body: content,
                  bottomNavigationBar: actions),
            ));
      },
    );
  }
}
