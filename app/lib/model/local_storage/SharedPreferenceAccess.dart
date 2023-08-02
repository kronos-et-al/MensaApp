import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:app/view_model/repository/interface/ILocalStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../view_model/repository/data_classes/filter/Sorting.dart';
import '../../view_model/repository/data_classes/meal/FoodType.dart';

/// This class accesses the shared preferences and uses it as local storage.
class SharedPreferenceAccess implements ILocalStorage {
  final SharedPreferences _pref;

  /// This constructor creates a new instance of the shared preference access.
  SharedPreferenceAccess(this._pref);

  @override
  String? getClientIdentifier() {
    String? clientIdentifier = _pref.getString('clientIdentifier');
    if (clientIdentifier == null) {
      var uuid = const Uuid();
      clientIdentifier = uuid.v4();
      _pref.setString('clientIdentifier', clientIdentifier);
    }
    return clientIdentifier;
  }

  @override
  MensaColorScheme? getColorScheme() {
    final colorScheme = _pref.getString('colorScheme');
    return MensaColorScheme.values.firstWhere(
        (e) => e.toString() == colorScheme,
        orElse: () => MensaColorScheme.system);
  }

  @override
  FilterPreferences? getFilterPreferences() {
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
      foodTypeEnum = List.of(categories.map((e) =>
          FoodType.values.firstWhere((element) => element.toString() == e)));
    }

    List<Allergen>? allergensEnum;
    if (allergens != null) {
      allergensEnum = List.of(allergens.map((e) =>
          Allergen.values.firstWhere((element) => element.toString() == e)));
    }

    List<Frequency>? frequencyEnum;
    if (frequency != null) {
      frequencyEnum = List.of(frequency.map((e) =>
          Frequency.values.firstWhere((element) => element.toString() == e)));
    }

    Sorting? sortedByEnum;
    if (sortedBy != null) {
      sortedByEnum = Sorting.values.firstWhere((e) => e.toString() == sortedBy);
    }

    // return filter preferences
    return FilterPreferences(
        categories: foodTypeEnum,
        allergens: allergensEnum,
        price: price,
        rating: rating,
        frequency: frequencyEnum,
        onlyFavorite: onlyFavorites,
        sortedBy: sortedByEnum,
        ascending: ascending);
  }

  @override
  MealPlanFormat? getMealPlanFormat() {
    final mealPlanFormat = _pref.getString('mealPlanFormat');
    return MealPlanFormat.values.firstWhere(
        (e) => e.toString() == mealPlanFormat,
        orElse: () => MealPlanFormat.grid);
  }

  @override
  PriceCategory? getPriceCategory() {
    final String? priceCategory = _pref.getString('priceCategory');
    return PriceCategory.values.firstWhere((e) => e.toString() == priceCategory,
        orElse: () => PriceCategory.student);
  }

  @override
  Future<void> setClientIdentifier(String identifier) async {
    await _pref.setString('clientIdentifier', identifier);
  }

  @override
  Future<void> setColorScheme(MensaColorScheme scheme) async {
    await _pref.setString('colorScheme', scheme.toString());
  }

  @override
  Future<void> setFilterPreferences(FilterPreferences filter) async {
    await _pref.setStringList('filterCategories',
        List.of(filter.categories.map((e) => e.toString())));
    await _pref.setStringList(
        'filterAllergens', List.of(filter.allergens.map((e) => e.toString())));
    await _pref.setInt('filterPrice', filter.price);
    await _pref.setInt('filterRating', filter.rating);
    await _pref.setStringList(
        'filterFrequency', List.of(filter.frequency.map((e) => e.toString())));
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
  String? getCanteen() {
    final canteen = _pref.getString('canteen');
    return canteen;
  }

  @override
  Future<void> setCanteen(String canteen) async {
    await _pref.setString('canteen', canteen);
  }
}
