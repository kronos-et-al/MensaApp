import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/buttons/MensaCtaButton.dart';
import 'package:app/view/core/buttons/MensaIconButton.dart';
import 'package:app/view/core/dialogs/MensaFullscreenDialog.dart';
import 'package:app/view/core/icons/allergens/AllergenIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationBackIcon.dart';
import 'package:app/view/core/selection_components/MensaSlider.dart';
import 'package:app/view/core/selection_components/MensaToggle.dart';
import 'package:app/view/filter/MensaButtonGroup.dart';
import 'package:app/view/filter/MensaButtonGroupEntry.dart';
import 'package:app/view/filter/MensaFilterIconCheckbox.dart';
import 'package:app/view/filter/MensaFilterIconCheckboxGroup.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

// todo padding
class FilterDialog extends StatefulWidget {
  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  FilterPreferences _preferences = FilterPreferences();

  @override
  Widget build(BuildContext context) {
    return MensaFullscreenDialog(
      appBar: MensaAppBar(
          appBarHeight: kToolbarHeight * 1.25,
          child: Row(
            children: [
              MensaIconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: NavigationBackIcon()),
              Text(
                FlutterI18n.translate(context, "filter.filterTitle"),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // todo temporary disable or enable filter
            ],
          )),
      content: Consumer<IMealAccess>(
        builder: (context, mealAccess, child) => FutureBuilder(
          future: mealAccess.getFilterPreferences(),
          builder: (BuildContext context, filterPreferences) {
            if (!filterPreferences.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (filterPreferences.hasError) {
              return const Center(child: Text("Error"));
            }
            _preferences = filterPreferences.requireData;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(FlutterI18n.translate(context, "filter.foodType")),
                  MensaButtonGroup(
                      value: _getValueCategory(_preferences.categories),
                      onChanged: (value) {
                        _setValueCategory(value, _preferences);
                        setState(() {
                          _preferences = _preferences;
                        });
                      },
                      entries: _getAllFoodTypeEntries(context)),
                  // todo checkboxes
                  Text(FlutterI18n.translate(context, "filter.allergensTitle")),
                  MensaFilterIconCheckboxGroup<Allergen>(
                      items: _getAllAllergen(context),
                      selectedValues: _preferences.allergens,
                      onChanged: (value) {
                        _preferences.allergens = value;
                      }),
                  Text(FlutterI18n.translate(context, "filter.priceTitle")),
                  MensaSlider(
                      onChanged: (value) => _preferences.price = value.round(),
                      value: _preferences.price.toDouble(),
                      min: 0,
                      max: 10),
                  MensaSlider(
                    onChanged: (value) => _preferences.rating = value.round(),
                    value: _preferences.rating.toDouble(),
                    min: 1,
                    max: 1,
                  ),
                  MensaToggle(
                      onChanged: (value) => _preferences.onlyFavorite = value,
                      value: _preferences.onlyFavorite,
                      label: FlutterI18n.translate(
                          context, "filter.favoritesOnlyTitle")),
                  Text(FlutterI18n.translate(context, "filter.frequencyTitle")),
                  MensaButtonGroup(
                      value: _getValueFrequency(_preferences.frequency),
                      onChanged: (value) =>
                          _setValueFrequency(value, _preferences),
                      entries: _getAllFrequencyEntries(context)),
                  Text(FlutterI18n.translate(context, "filter.sortByTitle")),
                  Row(
                    children: [
                      // todo SortDropdown in Expanded
                      // todo Icon for ascending / descending
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: Row(
        children: [
          Spacer(),
          MensaCtaButton(
              onPressed: () {
                context
                    .read<IMealAccess>()
                    .changeFilterPreferences(_preferences);
                Navigator.of(context).pop();
              },
              text: FlutterI18n.translate(context, "filter.apply")),
        ],
      ),
    );
  }

  static _setValueFrequency(Frequency frequency, FilterPreferences filter) {
    if (frequency == Frequency.newMeal) {
      filter.setNewFrequency();
      return;
    }

    if (frequency == Frequency.rare) {
      filter.setRareFrequency();
      return;
    }

    filter.setAllFrequencies();
  }

  static Frequency _getValueFrequency(List<Frequency> frequencies) {
    if (frequencies.contains(Frequency.normal)) {
      return Frequency.normal;
    }

    if (frequencies.contains(Frequency.rare)) {
      return Frequency.rare;
    }

    return Frequency.newMeal;
  }

  static List<MensaButtonGroupEntry<Frequency>> _getAllFrequencyEntries(
      BuildContext context) {
    final List<MensaButtonGroupEntry<Frequency>> entries = [];

    entries.add(MensaButtonGroupEntry(
        title: FlutterI18n.translate(context, "filter.frequencySectionAll"),
        value: Frequency.normal));
    entries.add(MensaButtonGroupEntry(
        title: FlutterI18n.translate(context, "filter.frequencySectionRare"),
        value: Frequency.rare));
    entries.add(MensaButtonGroupEntry(
        title: FlutterI18n.translate(context, "filter.frequencySectionNew"),
        value: Frequency.newMeal));

    return entries;
  }

  static List<MensaFilterIconCheckbox<Allergen>> _getAllAllergen(
      BuildContext context) {
    List<MensaFilterIconCheckbox<Allergen>> entries = [];

    for (final allergen in Allergen.values) {
      entries.add(MensaFilterIconCheckbox(
        icon: AllergenIcon(
          allergen: allergen,
        ),
        text: FlutterI18n.translate(context, "allergen.${allergen.name}"),
        value: allergen,
      ));
    }

    return entries;
  }

  static List<MensaButtonGroupEntry<FoodType>> _getAllFoodTypeEntries(
      BuildContext context) {
    final List<MensaButtonGroupEntry<FoodType>> entries = [];

    entries.add(MensaButtonGroupEntry(
        title: FlutterI18n.translate(context, "filter.foodTypeSectionAll"),
        value: FoodType.beef));
    entries.add(MensaButtonGroupEntry(
        title:
            FlutterI18n.translate(context, "filter.foodTypeSectionVegetarian"),
        value: FoodType.vegetarian));
    entries.add(MensaButtonGroupEntry(
        title: FlutterI18n.translate(context, "filter.foodTypeSectionVegan"),
        value: FoodType.vegan));

    return entries;
  }

  static _setValueCategory(FoodType type, FilterPreferences access) {
    if (type == FoodType.vegan) {
      access.setCategoriesVegan();
      return;
    }

    if (type == FoodType.vegetarian) {
      access.setCategoriesVegetarian();
      return;
    }

    access.setAllCategories();
  }

  static FoodType _getValueCategory(List<FoodType> types) {
    switch (types.length) {
      case 1:
        return FoodType.vegan;
      case 2:
        return FoodType.vegetarian;
      default:
        return FoodType.beef;
    }
  }
}
