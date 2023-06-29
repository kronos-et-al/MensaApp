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

  /// initializes all not committed parameters with standard-values that allows all meals to be displayed
  FilterPreferences({
    List<FoodType>? categories,
    List<Allergen>? allergens,
    int? price,
    int? rating,
    List<Frequency>? frequency,
    bool? onlyFavorite,
    Sorting? sortedBy,
    bool? ascending
  })
      : _categories = categories ?? _getAllFoodTypes(),
        _allergens = allergens ?? _getAllAllergen(),
        _price = price ?? 10,
        _rating = rating ?? 0,
        _frequency = frequency ?? _getAllFrequencies(),
        _onlyFavorite = onlyFavorite ?? false,
        _sortedBy = sortedBy ?? Sorting.line,
        _ascending = ascending ?? true;

  /// returns the food categories that are displayed
  List<FoodType> get categories => _categories;

  /// This method sets the categories so all meals are shown.
  setCategoriesAll() {
    _categories = _getAllFoodTypes();
  }

  /// This method adds a special type of meat or the category unknown to the categories that are shown.
  addMealCategory(FoodType foodType) {
    if ([FoodType.beef, FoodType.fish, FoodType.pork].contains(foodType)) {
      _categories.add(foodType);
    }
  }

  /// This method removes a special type of meat or the category unknown from the categories that are shown.
  removeMealCategory(FoodType foodType) {
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
  List<Allergen> get allergens => _allergens;

  /// add a allergen to the list of allergens that should be inside meals shown on the meal plan
  addAllergen(Allergen allergen) {
    _allergens.add(allergen);
  }

  /// remove an allergen to the list of allergens that should be inside meals shown on the meal plan
  removeAllergen(Allergen allergen) {
    _allergens.remove(allergen);
  }

  /// returns if the sorting of the meals is ascending or descending
  bool get ascending => _ascending;

  /// set a new value for the order of the meals
  set ascending(bool value) {
    _ascending = value;
  }

  /// returns the value which specifies the order of the meals
  Sorting get sortedBy => _sortedBy;

  /// sets a new value for the value that orders the meals
  set sortedBy(Sorting value) {
    _sortedBy = value;
  }

  /// returns if only favorites should be displayed
  bool get onlyFavorite => _onlyFavorite;

  /// sets if only favorites should be displayed
  set onlyFavorite(bool value) {
    _onlyFavorite = value;
  }

  /// returns the classes of Frequency that should be displayed
  List<Frequency> get frequency => _frequency;

  /// only new meals are to be shown
  setNewFrequency() {
    _frequency = [Frequency.newMeal];
  }

  /// only rare meals are to be shown
  setRareFrequency() {
    _frequency = [Frequency.rare];
  }

  /// all frequencies are to be shown
  setAllFrequencies() {
    _frequency = _getAllFrequencies();
  }

  /// returns the minimal rating of a meal to be shown
  int get rating => _rating;

  /// sets the minimal rating of a meal to be shown
  set rating(int value) {
    _rating = value;
  }

  /// returns the maximal price of a meal to be shown
  int get price => _price;

  /// sets the maximal price of a meal to be shown
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
}