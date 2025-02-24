import 'package:app/view/core/information_display/MealMainEntry.dart';
import 'package:app/view/core/information_display/MealSideEntry.dart';
import 'package:app/view/detail_view/MealAccordionInfo.dart';
import 'package:flutter/material.dart';

/// This class is used to display a meal in an accordion.
class MealAccordion extends StatelessWidget {
  final bool _isExpanded;
  final MealMainEntry? _mainEntry;
  final MealSideEntry? _sideEntry;
  final MealAccordionInfo _info;
  final Function()? _onTap;
  final Color? _backgroundColor;
  final Color? _expandedColor;

  /// Creates a new MealAccordion.
  const MealAccordion(
      {super.key,
      required bool isExpanded,
      MealMainEntry? mainEntry,
      MealSideEntry? sideEntry,
      required MealAccordionInfo info,
      Function()? onTap,
      Color? backgroundColor,
      Color? expandedColor})
      : _isExpanded = isExpanded,
        _mainEntry = mainEntry,
        _sideEntry = sideEntry,
        _info = info,
        _onTap = onTap,
        _backgroundColor = backgroundColor,
        _expandedColor = expandedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: _isExpanded
              ? _expandedColor ?? Theme.of(context).colorScheme.surfaceDim
              : _backgroundColor ?? Theme.of(context).colorScheme.surface,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
          child: InkWell(
              splashColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.0),
              onTap: _onTap,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  child: Column(
                    children: [
                      _mainEntry ?? _sideEntry ?? Container(),
                      Row(
                        children: [
                          Expanded(
                              child: _isExpanded
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 40),
                                      child: _info)
                                  : Container()),
                        ],
                      ),
                      _isExpanded ? const SizedBox(height: 4) : Container(),
                    ],
                  ))),
        ));
  }
}
