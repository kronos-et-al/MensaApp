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

  /// Creates a new MealAccordion.
  /// @param key The key to identify this widget.
  /// @param isExpanded Whether the accordion is expanded.
  /// @param mainEntry The main entry to display.
  /// @param sideEntry The side entry to display.
  /// @param info The MealAccordionInfo to display in the expanded MealAccordion.
  /// @param onTap The function that is called when the MealAccordion is tapped.
  /// @returns A new MealAccordion.
  const MealAccordion(
      {super.key,
      required bool isExpanded,
      MealMainEntry? mainEntry,
      MealSideEntry? sideEntry,
      required MealAccordionInfo info,
      Function()? onTap})
      : _isExpanded = isExpanded,
        _mainEntry = mainEntry,
        _sideEntry = sideEntry,
        _info = info,
        _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: _isExpanded
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.background,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
          child: InkWell(
              borderRadius: BorderRadius.circular(4.0),
              onTap: _onTap,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: Column(
                    children: [
                      _mainEntry ?? _sideEntry ?? Container(),
                      _isExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: _info)
                          : Container(),
                    ],
                  ))),
        ));
  }
}
