
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/settings/ColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:app/view_model/repository/interface/ILocalStorage.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../view_model/repository/data_classes/filter/Sorting.dart';
import '../../view_model/repository/data_classes/meal/FoodType.dart';

/// This class accesses the shared preferences and uses it as local storage.
class SharedPreferenceAccess implements ILocalStorage {
  final SharedPreferences _pref;

  /// This constructor creates a new instance of the shared preference access.
  /// @param _pref The shared preferences.
  /// @return A new instance of the shared preference access.
  SharedPreferenceAccess(this._pref);

  @override
  Future<String> getClientIdentifier() async {
    final clientIdentifier = _pref.getString('clientIdentifier') ?? "";
    return Future.value(clientIdentifier);
  }

  @override
  Future<ColorScheme> getColorScheme() async {
    final colorScheme = _pref.getString('colorScheme');
    return Future.value(ColorScheme.values.firstWhere((e) => e.toString() == colorScheme));
  }

  @override
  Future<FilterPreferences> getFilterPreferences() async {
    // get data from shared preferences
    final categories = _pref.getStringList('filterCategories');
    final allergens = _pref.getStringList('filterAllergens');
    final price = _pref.getInt('filterPrice');
    final rating = _pref.getInt('filterRating');
    final frequency = _pref.getStringList('filterFrequency');
    final onlyFavorites = _pref.getBool('filterFavorite');
    final sortedBy = _pref.getString('filterSort');
    final ascending = _pref.getBool('filterSortAscending');

    // convert values to right format
    List<FoodType>? foodTypeEnum;
    if (categories != null) {
      foodTypeEnum = List.of(categories.map((e) => FoodType.values.firstWhere((element) => element.toString() == e)));
    }

    List<Allergen>? allergensEnum;
    if (allergens != null) {
      allergensEnum = List.of(allergens.map((e) => Allergen.values.firstWhere((element) => element.toString() == e)));
    }

    List<Frequency>? frequencyEnum;
    if (frequency != null) {
      frequencyEnum = List.of(frequency.map((e) => Frequency.values.firstWhere((element) => element.toString() == e)));
    }

    Sorting? sortedByEnum;
    if (sortedBy != null) {
       sortedByEnum = Sorting.values.firstWhere((e) => e.toString() == sortedBy);
    }

    // return filter preferences
    return Future<FilterPreferences>.value(FilterPreferences(
      categories: foodTypeEnum,
      allergens: allergensEnum,
      price: price,
      rating: rating,
      frequency: frequencyEnum,
      onlyFavorite: onlyFavorites,
      sortedBy: sortedByEnum,
      ascending: ascending
    ));
  }

  @override
  Future<MealPlanFormat> getMealPlanFormat() async {
    final mealPlanFormat = _pref.getString('mealPlanFormat');
    return Future.value(MealPlanFormat.values.firstWhere((e) => e.toString() == mealPlanFormat));
  }

  @override
  Future<PriceCategory> getPriceCategory() async {
    final priceCategory = _pref.getString('priceCategory');
    return Future.value(PriceCategory.values.firstWhere((e) => e.toString() == priceCategory));

  }

  @override
  Future<void> setClientIdentifier(String identifier) async {
    await _pref.setString('clientIdentifier', identifier);
  }

  @override
  Future<void> setColorScheme(ColorScheme scheme) async {
    await _pref.setString('colorScheme', scheme.toString());
  }

  @override
  Future<void> setFilterPreferences(FilterPreferences filter) async {
    await _pref.setStringList('filterCategories', List.of(filter.categories.map((e) => e.toString())));
    await _pref.setStringList('filterAllergens', List.of(filter.allergens.map((e) => e.toString())));
    await _pref.setInt('filterPrice', filter.price);
    await _pref.setInt('filterRating', filter.rating);
    await _pref.setStringList('filterFrequency', List.of(filter.frequency.map((e) => e.toString())));
    await _pref.setBool('filterFavorite', filter.onlyFavorite);
    await _pref.setString('filterSort', filter.sortedBy.toString());
    await _pref.setBool('filterSortAscending', filter.ascending);
  }

  @override
  Future<void> setMealPlanFormat(MealPlanFormat format) async {
    await _pref.setString('mealPlanFormat', format.toString());
  }

  @override
  Future<void> setPriceCategory(PriceCategory category) async {
    await _pref.setString('priceCategory', category.toString());
  }

  @override
  Future<String> getCanteen() async {
    final canteen = _pref.getString('canteen') ?? "";
    return Future.value(canteen);
  }

  @override
  Future<void> setCanteen(String canteen) async {
    await _pref.setString('canteen', canteen);
  }
}