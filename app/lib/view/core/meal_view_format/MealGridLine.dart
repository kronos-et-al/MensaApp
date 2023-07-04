import 'package:app/view/core/meal_view_format/MealGridEntry.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Mealplan.dart';
import 'package:flutter/material.dart';

/// Displays the section for the MealList with all meals of a line.
class MealGridLine extends StatelessWidget {
  final Mealplan _mealPlan;

  /// Creates a MealListLine.
  /// @param mealPlan The MealPlan to display.
  /// @param key The key to use for this widget.
  /// @return A MealListLine.
  const MealGridLine({super.key, required Mealplan mealPlan})
      : _mealPlan = mealPlan;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(_mealPlan.line.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, height: 1.5)),
      ),
      LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
                physics: _PageScrollPhysics(
                    itemDimension: constraints.maxWidth * 0.9),
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _mealPlan.meals
                      .map((e) => MealGridEntry(
                            meal: e,
                            width: constraints.maxWidth * 0.9,
                          ))
                      .toList(),
                )),
              )),
    ]);
  }
}

class _PageScrollPhysics extends ScrollPhysics {
  final double _itemDimension;

  const _PageScrollPhysics({required itemDimension, super.parent})
      : _itemDimension = itemDimension;

  @override
  _PageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _PageScrollPhysics(
        itemDimension: _itemDimension, parent: buildParent(ancestor));
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / _itemDimension;
  }

  double _getPixels(double page) {
    return page * _itemDimension - _itemDimension * 0.05 - 3;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
