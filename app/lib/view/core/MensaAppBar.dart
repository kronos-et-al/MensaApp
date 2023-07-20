import 'package:app/view/core/selection_components/MensaDropdown.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MensaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? _bottom;
  final double? _appBarHeight;

  MensaAppBar({super.key, PreferredSizeWidget? bottom, double? appBarHeight})
      : _appBarHeight = appBarHeight,
        _bottom = bottom,
        preferredSize =
            _PreferredAppBarSize(appBarHeight, bottom?.preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: preferredSize.height,
        child: Column(children: [
          Consumer<IMealAccess>(
              builder: (context, mealAccess, child) => FutureBuilder(
                    future: mealAccess.getAvailableCanteens(),
                    builder: (context, availableCanteens) => FutureBuilder(
                        future: mealAccess.getCanteen(),
                        builder: (context, selectedCanteen) {
                          if (selectedCanteen.hasData) {
                            return SizedBox(
                                height: _appBarHeight,
                                child: MensaDropdown<Canteen>(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    onChanged: (canteen) => {
                                          if (canteen != null)
                                            {
                                              mealAccess.changeCanteen(canteen),
                                            }
                                        },
                                    value: selectedCanteen.requireData,
                                    items: availableCanteens.requireData
                                        .map((canteen) =>
                                            MensaDropdownEntry<Canteen>(
                                              value: canteen,
                                              label: canteen.name,
                                            ))
                                        .toList()));
                          }
                          return const SizedBox.shrink();
                        }),
                  )),
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
