import 'package:flutter/foundation.dart';

import 'Sorting.dart';
import 'Frequency.dart';
import '../meal/Allergen.dart';
import '../meal/FoodType.dart';

/// This class contains all filter preferences.
class FilterPreferences {
  List<FoodType> _categories;
  List<Allergen> _allergens;
  int _price;
  int _rating;
  List<Frequency> _frequency;
  bool _onlyFavorite;
  Sorting _sortedBy;
  bool _ascending;

  /// Creates a new [FilterPreferences] object.
  /// Initializes all not committed parameters with standard-values that allows all meals to be displayed.
  FilterPreferences(
      {List<FoodType>? categories,
      List<Allergen>? allergens,
      int? price,
      int? rating,
      List<Frequency>? frequency,
      bool? onlyFavorite,
      Sorting? sortedBy,
      bool? ascending})
      : _categories = categories ?? _getAllFoodTypes(),
        _allergens = allergens ?? _getAllAllergen(),
        _price = price ?? 1000,
        _rating = rating ?? 1,
        _frequency = frequency ?? _getAllFrequencies(),
        _onlyFavorite = onlyFavorite ?? false,
        _sortedBy = sortedBy ?? Sorting.line,
        _ascending = ascending ?? true;

  /// Returns the food categories that are displayed.
  List<FoodType> get categories => _categories;

  /// Sets the categories so all meals are shown.
  setAllCategories() {
    _categories = _getAllFoodTypes();
  }

  /// Adds a special type of meat or the category unknown to the categories that are shown.
  addMeatCategory(FoodType foodType) {
    if ([FoodType.beef, FoodType.fish, FoodType.pork].contains(foodType)) {
      _categories.add(foodType);
    }
  }

  /// Removes a special type of meat or the category unknown from the categories that are shown.
  removeMeatCategory(FoodType foodType) {
    if ([FoodType.beef, FoodType.fish, FoodType.pork].contains(foodType)) {
      _categories.remove(foodType);
    }
  }

  /// Sets the categories so only vegetarian categories are shown.
  setCategoriesVegetarian() {
    _categories = [FoodType.vegan, FoodType.vegetarian, FoodType.unknown];
  }

  /// Sets the categories so only vegan categories are shown.
  setCategoriesVegan() {
    _categories = [FoodType.vegan, FoodType.unknown];
  }

  /// Adds the unknown category to the categories that are shown.
  addCategoryUnknown() {
    _categories.add(FoodType.unknown);
  }

  /// Removes the unknown category from the categories that are shown.
  removeCategoryUnknown() {
    _categories.remove(FoodType.unknown);
  }

  /// Returns the allergens that should be inside meals shown on the meal plan.
  List<Allergen> get allergens => _allergens;

  /// Sets the list of allergens that should be inside meals shown on the meal plan.
  set allergens(List<Allergen> value) {
    _allergens = value;
  }

  /// Returns if the sorting of the meals is ascending or descending.
  bool get ascending => _ascending;

  /// Set a new value for the order of the meals.
  set ascending(bool value) {
    _ascending = value;
  }

  /// Returns the value which specifies the order of the meals.
  Sorting get sortedBy => _sortedBy;

  /// Sets a new value for the value that orders the meals.
  set sortedBy(Sorting value) {
    _sortedBy = value;
  }

  /// Returns if only favorites should be displayed.
  bool get onlyFavorite => _onlyFavorite;

  /// Sets if only favorites should be displayed.
  set onlyFavorite(bool value) {
    _onlyFavorite = value;
  }

  /// Returns the classes of [Frequency] that should be displayed.
  List<Frequency> get frequency => _frequency;

  /// Sets the frequency so only new meals are shown.
  setNewFrequency() {
    _frequency = [Frequency.newMeal];
  }

  // todo wollen wir hier auch neue Gerichte?
  /// Sets the frequency so only rare meals are shown.
  setRareFrequency() {
    _frequency = [Frequency.rare];
  }

  /// Sets the frequency so all meals are shown.
  setAllFrequencies() {
    _frequency = _getAllFrequencies();
  }

  /// Returns the minimal rating of a meal to be shown.
  int get rating => _rating;

  /// Sets the minimal rating of a meal to be shown.
  set rating(int value) {
    _rating = value;
  }

  /// Returns the maximal price of a meal to be shown.
  int get price => _price;

  /// Sets the maximal price of a meal to be shown.
  set price(int value) {
    _price = value;
  }

  /// Returns a list of all frequencies.
  static List<Frequency> _getAllFrequencies() {
    List<Frequency> list = [];
    for (Frequency frequency in Frequency.values) {
      list.add(frequency);
    }
    return list;
  }

  /// Returns a list of all allergens.
  static List<Allergen> _getAllAllergen() {
    List<Allergen> list = [];
    for (Allergen allergen in Allergen.values) {
      list.add(allergen);
    }
    return list;
  }

  /// Returns a list of all food types.
  static List<FoodType> _getAllFoodTypes() {
    List<FoodType> list = [];
    for (FoodType foodType in FoodType.values) {
      list.add(foodType);
    }
    return list;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterPreferences &&
          runtimeType == other.runtimeType &&
          listEquals(_categories, other._categories) &&
          listEquals(_allergens, other._allergens) &&
          _price == other._price &&
          _rating == other._rating &&
          listEquals(_frequency, other._frequency) &&
          _onlyFavorite == other._onlyFavorite &&
          _sortedBy == other._sortedBy &&
          _ascending == other._ascending;

  @override
  int get hashCode =>
      _categories.hashCode ^
      _allergens.hashCode ^
      _price.hashCode ^
      _rating.hashCode ^
      _frequency.hashCode ^
      _onlyFavorite.hashCode ^
      _sortedBy.hashCode ^
      _ascending.hashCode;
}
