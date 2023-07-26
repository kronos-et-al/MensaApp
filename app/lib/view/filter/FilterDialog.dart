import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/dialogs/MensaFullscreenDialog.dart';
import 'package:app/view/core/icons/allergens/AllergenIcon.dart';
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
class FilterDialog {
  static void show(BuildContext context) {
    FilterPreferences preferences = FilterPreferences();

    MensaFullscreenDialog.show(
        context: context,
        appBar: MensaAppBar(
            appBarHeight: kToolbarHeight * 1.25,
            child: Row(
              children: [
                // todo icon back
                Text(
                  FlutterI18n.translate(context, "filter.filterTitle"),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // todo temporary disable or enable filter
              ],
            )),
        content: Consumer<IMealAccess>(
            builder: (context, mealAccess, child) => FutureBuilder(
                future: mealAccess.getFilterPreferences(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    preferences = snapshot.requireData;
                  }

                  // todo Scrollable
                  return Column(
                    children: [
                      Text(FlutterI18n.translate(context, "filter.foodType")),
                      MensaButtonGroup(
                          value: _getValueCategory(preferences.categories),
                          onChanged: (value) =>
                              _setValueCategory(value, preferences),
                          entries: _getAllFoodTypeEntries(context)),
                      // todo checkboxes
                      Text(FlutterI18n.translate(
                          context, "filter.allergensTitle")),
                      MensaFilterIconCheckboxGroup<Allergen>(
                          items: _getAllAllergen(context),
                          selectedValues: preferences.allergens,
                          onChanged: (value) {
                            preferences.allergens = value;
                          }),
                      Text(FlutterI18n.translate(context, "filter.priceTitle")),
                      MensaSlider(
                          onChanged: (value) => preferences.price = value,
                          value: preferences.price,
                          min: "0€",
                          max: "${FilterPreferences().price}€"),
                      Text(
                          FlutterI18n.translate(context, "filter.ratingTitle")),
                      MensaSlider(
                          onChanged: (value) => preferences.rating = value,
                          value: preferences.rating,
                          min: "5 Sterne",
                          max: "1 Stern"),
                      MensaToggle(
                          onChanged: (value) =>
                              preferences.onlyFavorite = value,
                          value: preferences.onlyFavorite,
                          label: FlutterI18n.translate(
                              context, "filter.favoritesOnlyTitle")),
                      Text(FlutterI18n.translate(
                          context, "filter.frequencyTitle")),
                      MensaButtonGroup(
                          value: _getValueFrequency(preferences.frequency),
                          onChanged: (value) =>
                              _setValueFrequency(value, preferences),
                          entries: _getAllFrequencyEntries(context)),
                      Text(
                          FlutterI18n.translate(context, "filter.sortByTitle")),
                      Row(
                        children: [
                          // todo SortDropdown in Expanded
                          // todo Icon for ascending / descending
                        ],
                      ),
                      MensaButton(
                          onPressed: () {
                            Navigator.pop(context);
                            mealAccess.changeFilterPreferences(preferences);
                          },
                          text: FlutterI18n.translate(
                              context, "filter.storeButton"))
                    ],
                  );
                })));
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
