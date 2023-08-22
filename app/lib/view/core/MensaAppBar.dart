import 'package:flutter/material.dart';

/// A custom AppBar that is used in the Mensa app.
class MensaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? _bottom;
  final Widget _child;
  final double _appBarHeight;

  /// Creates a new MensaAppBar.
  MensaAppBar(
      {super.key,
      PreferredSizeWidget? bottom,
      double appBarHeight = kToolbarHeight,
      required Widget child})
      : _appBarHeight = appBarHeight,
        _bottom = bottom,
        preferredSize =
            _PreferredAppBarSize(appBarHeight, bottom?.preferredSize.height),
        _child = child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: preferredSize.height,
        child: Column(children: [
          SizedBox(height: _appBarHeight, child: _child),
          if (_bottom != null) _bottom!
        ]));
  }

  @override
  final Size preferredSize;
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.appBarHeight, this.bottomHeight)
      : super.fromHeight(appBarHeight + (bottomHeight ?? 0));

  final double appBarHeight;
  final double? bottomHeight;
}
