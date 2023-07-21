import 'package:app/view/core/selection_components/MensaDropdown.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MensaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? _bottom;
  final Widget _child;
  final double? _appBarHeight;

  MensaAppBar(
      {super.key,
      PreferredSizeWidget? bottom,
      double? appBarHeight,
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
      : super.fromHeight(
            (appBarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? appBarHeight;
  final double? bottomHeight;
}
