import 'package:flutter/material.dart';

class MensaDialog {
  static void show(
      {required BuildContext context,
      required String title,
      Widget? content,
      Widget? actions,
      bool? barrierDismissible}) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: barrierDismissible ?? true,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: EdgeInsets.all(16), child: Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold))),
              if (content != null) content,
              if (actions != null) actions
            ]));
      },
    );
  }
}
