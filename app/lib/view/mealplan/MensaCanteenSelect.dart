import 'package:app/view/core/icons/navigation/NavigationArrowDownIcon.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:flutter/material.dart';

/// This class is the widget for selecting a canteen.
class MensaCanteenSelect extends StatelessWidget {
  final List<Canteen> _availableCanteens;
  final Canteen _selectedCanteen;
  final Function(Canteen) _onCanteenSelected;

  /// Creates a new MensaCanteenSelect.
  const MensaCanteenSelect(
      {super.key,
      required List<Canteen> availableCanteens,
      required Canteen selectedCanteen,
      required Function(Canteen) onCanteenSelected})
      : _availableCanteens = availableCanteens,
        _selectedCanteen = selectedCanteen,
        _onCanteenSelected = onCanteenSelected;

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).colorScheme.background, child: DropdownButtonHideUnderline(
        child: DropdownButton(
            dropdownColor: Theme.of(context).colorScheme.surface,
            selectedItemBuilder: (context) => _availableCanteens
                .map((e) => Row(children: [
                      const SizedBox(
                        width: 40,
                      ),
                      Container(
                        color: Theme.of(context).colorScheme.background,
                        alignment: Alignment.center,
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width -
                                2 * 8 -
                                2 * 40),
                        child: Text(
                          e.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )
                    ]))
                .toList(),
            icon: const NavigationArrowDownIcon(size: 32),
            value: _selectedCanteen.id,
            items: _availableCanteens
                .map((e) => DropdownMenuItem(
                    value: e.id, child: Center(child: Text(e.name))))
                .toList(),
            onChanged: (value) => _onCanteenSelected(_availableCanteens
                .firstWhere((element) => element.id == value)))));
  }
}
