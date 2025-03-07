import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

const _hints = ["tempFilter", "reportImages", "imageView", "hint"];

class Hint extends StatefulWidget {
  final bool allowRefresh;

  const Hint({super.key, this.allowRefresh = false});

  @override
  State<Hint> createState() => _HintState();
}

class _HintState extends State<Hint> {
  int _hintIndex;

  _HintState() : _hintIndex = Random().nextInt(_hints.length);

  @override
  Widget build(BuildContext context) {
    final text = Text(
      FlutterI18n.translate(context, "hint.${_hints[_hintIndex]}"),
      textAlign: widget.allowRefresh ? TextAlign.left : TextAlign.center,
    );

    return widget.allowRefresh
        ? InkWell(
          onTap:
              () => {
                if (widget.allowRefresh)
                  {
                    setState(() {
                      var newIdx = Random().nextInt(_hints.length);
                      if (newIdx == _hintIndex) {
                        newIdx = (newIdx + 1) % _hints.length;
                      }
                      _hintIndex = newIdx;
                    }),
                  },
              },
          borderRadius: BorderRadius.circular(4),
          child: text,
        )
        : text;
  }
}
