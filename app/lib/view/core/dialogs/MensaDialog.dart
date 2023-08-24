import 'package:flutter/material.dart';

/// This widget is used to display a dialog.
class MensaDialog extends StatelessWidget {
  final String _title;
  final Widget? _content;
  final Widget? _actions;

  /// Creates a new dialog instance.
  const MensaDialog(
      {super.key, required String title, Widget? content, Widget? actions})
      : _title = title,
        _content = content,
        _actions = actions;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      child: Dialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: Column(children: [
            Align(alignment: AlignmentDirectional.centerStart, child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(_title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.left,))),
            _content ?? Container(),
            _actions ?? Container()
          ])),
    ));
  }
}
