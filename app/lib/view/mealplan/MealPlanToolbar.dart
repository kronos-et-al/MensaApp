import 'package:flutter/material.dart';

class MealPlanToolbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget _child;
  final double _toolBarHeight;

  MealPlanToolbar({super.key, double toolBarHeight = kToolbarHeight, required Widget child})
      : _toolBarHeight = toolBarHeight,
        preferredSize = _PreferredAppBarSize(toolBarHeight),
        _child = child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: preferredSize.height,
        child: Column(children: [
          SizedBox(height: _toolBarHeight, child: _child),
        ]));
  }

  @override
  final Size preferredSize;
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.appBarHeight)
      : super.fromHeight(appBarHeight);

  final double appBarHeight;
}
