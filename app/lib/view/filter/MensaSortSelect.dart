import 'package:app/view/core/buttons/MensaTapable.dart';
import 'package:app/view/core/icons/filter/SortAscendingIcon.dart';
import 'package:app/view/core/icons/filter/SortDecendingIcon.dart';
import 'package:app/view/core/selection_components/MensaDropdown.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view/filter/MensaSortSelectEntry.dart';
import 'package:flutter/material.dart';

/// This widget is used to display a sort select.
class MensaSortSelect<T> extends StatelessWidget {
  final List<MensaSortSelectEntry<T>> _entries;
  final T _selectedEntry;
  final SortDirection _sortDirection;
  final Function(T) _onEntrySelected;
  final Function(SortDirection) _onSortDirectionSelected;

  /// Creates a new sort select.
  /// @param key The key to identify this widget.
  /// @param entries The entries to display.
  /// @param selectedEntry The selected entry.
  /// @param sortDirection The sort direction.
  /// @param onEntrySelected The function to call when an entry is selected.
  /// @param onSortDirectionSelected The function to call when the sort direction is selected.
  /// @returns A new sort select.
  const MensaSortSelect(
      {super.key,
      required List<MensaSortSelectEntry<T>> entries,
      required T selectedEntry,
      required SortDirection sortDirection,
      required Function(T) onEntrySelected,
      required Function(SortDirection) onSortDirectionSelected})
      : _entries = entries,
        _selectedEntry = selectedEntry,
        _onEntrySelected = onEntrySelected,
        _sortDirection = sortDirection,
        _onSortDirectionSelected = onSortDirectionSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: MensaDropdown(
                onChanged: (v) => _onEntrySelected(v),
                value: _selectedEntry,
                items: _entries
                    .map((e) => MensaDropdownEntry(
                          value: e.value,
                          label: e.label,
                        ))
                    .toList())),
        const SizedBox(
          width: 8,
        ),
        MensaTapable(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _sortDirection == SortDirection.ascending
                ? const SortAscendingIcon()
                : const SortDescendingIcon(),
          ),
          onTap: () => _onSortDirectionSelected(
              _sortDirection == SortDirection.ascending
                  ? SortDirection.descending
                  : SortDirection.ascending),
        )
      ],
    );
  }
}

enum SortDirection { ascending, descending }
