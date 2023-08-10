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

  /// Initializes all not committed parameters with standard-values that allows all meals to be displayed.
  /// @param categories The food types that are displayed.
  /// @param allergens The allergens that are displayed.
  /// @param price The maximal price of the meals that are displayed.
  /// @param rating The minimal rating of the meals that are displayed.
  /// @param frequency The frequency category that are displayed.
  /// @param onlyFavorite Only favorite meals are to be displayed.
  /// @param sortedBy The value which sorts the meals.
  /// @param ascending The order in which the meals are displayed.
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

  /// returns the food categories that are displayed
  /// @return The categories that are displayed.
  List<FoodType> get categories => _categories;

  /// This method sets the categories so all meals are shown.
  setAllCategories() {
    _categories = _getAllFoodTypes();
  }

  /// This method adds a special type of meat or the category unknown to the categories that are shown.
  /// @param foodType The meat type that is to be added.
  addMeatCategory(FoodType foodType) {
    if ([FoodType.beef, FoodType.fish, FoodType.pork].contains(foodType)) {
      _categories.add(foodType);
    }
  }

  /// This method removes a special type of meat or the category unknown from the categories that are shown.
  /// @param foodType The meat type that is to be added.
  removeMeatCategory(FoodType foodType) {
    if ([FoodType.beef, FoodType.fish, FoodType.pork].contains(foodType)) {
      _categories.remove(foodType);
    }
  }

  /// This method sets the categories so only vegetarian categories are shown.
  setCategoriesVegetarian() {
    _categories = [FoodType.vegan, FoodType.vegetarian, FoodType.unknown];
  }

  /// This method sets the categories so only vegan categories are shown.
  setCategoriesVegan() {
    _categories = [FoodType.vegan, FoodType.unknown];
  }

  /// This method adds the unknown category to the categories that are shown.
  addCategoryUnknown() {
    _categories.add(FoodType.unknown);
  }

  /// This method removes the unknown category from the categories that are shown.
  removeCategoryUnknown() {
    _categories.remove(FoodType.unknown);
  }

  /// returns the allergens that should be inside meals shown on the meal plan
  /// @return The allergens that should be inside meals shown on the meal plan
  List<Allergen> get allergens => _allergens;

  /// change the list of allergens that should be inside meals shown on the meal plan
  /// @param allergen The list of allergen that should be inside meals shown on the meal plan
  set allergens(List<Allergen> value) {
    _allergens = value;
  }

  /// returns if the sorting of the meals is ascending or descending
  /// @return If the sorting of the meals is ascending or descending
  bool get ascending => _ascending;

  /// set a new value for the order of the meals
  ///  @param value The new value for the order of the meals
  set ascending(bool value) {
    _ascending = value;
  }

  /// returns the value which specifies the order of the meals
  /// @return The value which specifies the order of the meals
  Sorting get sortedBy => _sortedBy;

  /// sets a new value for the value that orders the meals
  /// @param value The new value for the value that orders the meals
  set sortedBy(Sorting value) {
    _sortedBy = value;
  }

  /// returns if only favorites should be displayed
  /// @return If only favorites should be displayed
  bool get onlyFavorite => _onlyFavorite;

  /// sets if only favorites should be displayed
  /// @param value If only favorites should be displayed
  set onlyFavorite(bool value) {
    _onlyFavorite = value;
  }

  /// returns the classes of Frequency that should be displayed
  /// @return The classes of Frequency that should be displayed
  List<Frequency> get frequency => _frequency;

  /// only new meals are to be shown
  setNewFrequency() {
    _frequency = [Frequency.newMeal];
  }

  /// only rare meals are to be shown
  setRareFrequency() {
    _frequency = [Frequency.rare, Frequency.newMeal];
  }

  /// all frequencies are to be shown
  setAllFrequencies() {
    _frequency = _getAllFrequencies();
  }

  /// returns the minimal rating of a meal to be shown
  /// @return The minimal rating of a meal to be shown
  int get rating => _rating;

  /// sets the minimal rating of a meal to be shown
  /// @param value The minimal rating of a meal to be shown
  set rating(int value) {
    _rating = value;
  }

  /// returns the maximal price of a meal to be shown
  /// @return The maximal price of a meal to be shown
  int get price => _price;

  /// sets the maximal price of a meal to be shown
  /// @param value The maximal price of a meal to be shown
  set price(int value) {
    _price = value;
  }

  /// returns all frequencies
  static List<Frequency> _getAllFrequencies() {
    List<Frequency> list = [];
    for (Frequency frequency in Frequency.values) {
      list.add(frequency);
    }
    return list;
  }

  /// returns all allergens
  static List<Allergen> _getAllAllergen() {
    List<Allergen> list = [];
    for (Allergen allergen in Allergen.values) {
      list.add(allergen);
    }
    return list;
  }

  /// returns all food types
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
