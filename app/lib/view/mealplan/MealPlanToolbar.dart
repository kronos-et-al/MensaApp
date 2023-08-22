import 'package:flutter/material.dart';

/// This class represents the toolbar of the meal plan.
class MealPlanToolbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget _child;
  final double _toolBarHeight;

  /// Creates a new meal plan toolbar.
  MealPlanToolbar(
      {super.key, double toolBarHeight = kToolbarHeight, required Widget child})
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
  _PreferredAppBarSize(this.appBarHeight) : super.fromHeight(appBarHeight);

  final double appBarHeight;
}
