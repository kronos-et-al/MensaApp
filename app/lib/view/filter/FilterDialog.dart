import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaCtaButton.dart';
import 'package:app/view/core/buttons/MensaIconButton.dart';
import 'package:app/view/core/dialogs/MensaFullscreenDialog.dart';
import 'package:app/view/core/icons/allergens/AllergenIcon.dart';
import 'package:app/view/core/icons/filter/FilterRestoreIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationBackIcon.dart';
import 'package:app/view/core/selection_components/MensaCheckbox.dart';
import 'package:app/view/core/selection_components/MensaSlider.dart';
import 'package:app/view/core/selection_components/MensaToggle.dart';
import 'package:app/view/filter/MensaButtonGroup.dart';
import 'package:app/view/filter/MensaButtonGroupEntry.dart';
import 'package:app/view/filter/MensaFilterIconCheckbox.dart';
import 'package:app/view/filter/MensaFilterIconCheckboxGroup.dart';
import 'package:app/view/filter/MensaSortSelect.dart';
import 'package:app/view/filter/MensaSortSelectEntry.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/filter/Sorting.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// This widget is used to display the filter dialog.
class FilterDialog extends StatefulWidget {
  /// Creates a new filter dialog.
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  FilterPreferences preferences = FilterPreferences();

  final TextStyle headingTextStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return MensaFullscreenDialog(
      appBar: MensaAppBar(
          appBarHeight: kToolbarHeight,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  MensaIconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const NavigationBackIcon()),
                  Text(
                    FlutterI18n.translate(context, "filter.filterTitle"),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  MensaIconButton(
                      onPressed: () {
                        context.read<IMealAccess>().resetFilterPreferences();
                        setState(() {
                          preferences = FilterPreferences();
                        });
                      },
                      icon: const FilterRestoreIcon()),
                ],
              ))),
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
            preferences = filterPreferences.requireData;
            return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(FlutterI18n.translate(context, "filter.foodType"),
                          style: headingTextStyle),
                      const SizedBox(
                        height: 8,
                      ),
                      MensaButtonGroup<int>(
                          value: _getValueCategory(preferences.categories),
                          onChanged: (value) {
                            _setValueCategory(value, preferences);
                            setState(() {
                              preferences = preferences;
                            });
                          },
                          entries: _getAllFoodTypeEntries(context)),
                      _getValueCategory(preferences.categories) == 0
                          ? Column(
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                MensaCheckbox(
                                  label: FlutterI18n.translate(
                                      context, "filter.foodTypeSelectionBeef"),
                                  value: preferences.categories
                                          .contains(FoodType.beef) ||
                                      preferences.categories
                                          .contains(FoodType.beefAw),
                                  onChanged: (value) {
                                    if (value) {
                                      preferences.categories
                                          .add(FoodType.beef);
                                      preferences.categories
                                          .add(FoodType.beefAw);
                                    } else {
                                      preferences.categories
                                          .remove(FoodType.beef);
                                      preferences.categories
                                          .remove(FoodType.beefAw);
                                    }
                                    setState(() {
                                      preferences = preferences;
                                    });
                                  },
                                ),
                                MensaCheckbox(
                                  label: FlutterI18n.translate(
                                      context, "filter.foodTypeSelectionPork"),
                                  value: preferences.categories
                                          .contains(FoodType.pork) ||
                                      preferences.categories
                                          .contains(FoodType.porkAw),
                                  onChanged: (value) {
                                    if (value) {
                                      preferences.categories
                                          .add(FoodType.pork);
                                      preferences.categories
                                          .add(FoodType.porkAw);
                                    } else {
                                      preferences.categories
                                          .remove(FoodType.pork);
                                      preferences.categories
                                          .remove(FoodType.porkAw);
                                    }
                                    setState(() {
                                      preferences = preferences;
                                    });
                                  },
                                ),
                                MensaCheckbox(
                                  label: FlutterI18n.translate(
                                      context, "filter.foodTypeSelectionFish"),
                                  value: preferences.categories
                                      .contains(FoodType.fish),
                                  onChanged: (value) {
                                    if (value) {
                                      preferences.categories
                                          .add(FoodType.fish);
                                    } else {
                                      preferences.categories
                                          .remove(FoodType.fish);
                                    }
                                    setState(() {
                                      preferences = preferences;
                                    });
                                  },
                                )
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        FlutterI18n.translate(context, "filter.allergensTitle"),
                        style: headingTextStyle,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(children: [
                        Expanded(
                            child: MensaFilterIconCheckboxGroup<Allergen>(
                                items: _getAllAllergen(context),
                                selectedValues: preferences.allergens,
                                onChanged: (value) {
                                  preferences.allergens = value;
                                  setState(() {
                                    preferences = preferences;
                                  });
                                }))
                      ]),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        FlutterI18n.translate(context, "filter.priceTitle"),
                        style: headingTextStyle,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(FlutterI18n.translate(
                              context, "filter.priceMin")),
                          const Spacer(),
                          Text(FlutterI18n.translate(
                              context, "filter.priceMax")),
                        ],
                      ),
                      MensaSlider(
                          onChanged: (value) {
                            preferences.price = value.round();
                            setState(() {
                              preferences = preferences;
                            });
                          },
                          label: NumberFormat.currency(decimalDigits: 2, symbol: "€", locale: FlutterI18n.currentLocale(context)?.languageCode).format(preferences.price / 100),
                          value: preferences.price.toDouble(),
                          min: 0,
                          max: 1000),
                      Text(
                        FlutterI18n.translate(context, "filter.ratingTitle"),
                        style: headingTextStyle,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(FlutterI18n.translate(
                              context, "filter.ratingMin")),
                          const Spacer(),
                          Text(FlutterI18n.translate(
                              context, "filter.ratingMax")),
                        ],
                      ),
                      MensaSlider(
                        onChanged: (value) {
                          preferences.rating = value.round();
                          setState(() {
                            preferences = preferences;
                          });
                        },
                        value: preferences.rating.toDouble(),
                        min: 1,
                        max: 5,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      MensaToggle(
                          onChanged: (value) {
                            preferences.onlyFavorite = value;
                            setState(() {
                              preferences = preferences;
                            });
                          },
                          value: preferences.onlyFavorite,
                          label: FlutterI18n.translate(
                              context, "filter.favoritesOnlyTitle")),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        FlutterI18n.translate(context, "filter.frequencyTitle"),
                        style: headingTextStyle,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      MensaButtonGroup(
                          value: _getValueFrequency(preferences.frequency),
                          onChanged: (value) {
                            _setValueFrequency(value, preferences);
                            setState(() {
                              preferences = preferences;
                            });
                          },
                          entries: _getAllFrequencyEntries(context)),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        FlutterI18n.translate(context, "filter.sortByTitle"),
                        style: headingTextStyle,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      MensaSortSelect(
                        entries: Sorting.values.map((e) => MensaSortSelectEntry(
                            label: FlutterI18n.translate(
                                context, "filter.sorting.${e.name}"),
                            value: e
                        )).toList(),
                        selectedEntry: preferences.sortedBy,
                        sortDirection: preferences.ascending ? SortDirection.ascending : SortDirection.descending,
                        onEntrySelected: (v) => {
                          setState(() {
                            preferences.sortedBy = v;
                          })
                        },
                        onSortDirectionSelected: (v) => {
                          setState(() {
                            preferences.ascending = v == SortDirection.ascending;
                          })
                        },
                      ),
                    ],
                  )),
            );
          },
        ),
      ),
      actions: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                  child: MensaCtaButton(
                      onPressed: () {
                        context
                            .read<IMealAccess>()
                            .changeFilterPreferences(preferences);
                        Navigator.of(context).pop();
                      },
                      text: FlutterI18n.translate(
                          context, "filter.storeButton"))),
            ],
          )),
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

  static List<MensaButtonGroupEntry<int>> _getAllFoodTypeEntries(
      BuildContext context) {
    final List<MensaButtonGroupEntry<int>> entries = [];

    entries.add(MensaButtonGroupEntry(
        title: FlutterI18n.translate(context, "filter.foodTypeSectionAll"),
        value: 0));
    entries.add(MensaButtonGroupEntry(
        title:
            FlutterI18n.translate(context, "filter.foodTypeSectionVegetarian"),
        value: 1));
    entries.add(MensaButtonGroupEntry(
        title: FlutterI18n.translate(context, "filter.foodTypeSectionVegan"),
        value: 2));

    return entries;
  }

  static _setValueCategory(int type, FilterPreferences access) {
    switch (type) {
      case 0:
        access.setAllCategories();
        return;
      case 1:
        access.setCategoriesVegetarian();
        return;
      case 2:
        access.setCategoriesVegan();
        return;
    }
  }

  static int _getValueCategory(List<FoodType> types) {
    if (types.contains(FoodType.beef) ||
        types.contains(FoodType.beefAw) ||
        types.contains(FoodType.pork) ||
        types.contains(FoodType.porkAw)) {
      return 0;
    }
    if (types.contains(FoodType.vegetarian)) {
      return 1;
    }
    if (types.contains(FoodType.vegan)) {
      return 2;
    }
    return 0;
  }
}
