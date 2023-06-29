import 'Sorting.dart';
import 'Frequency.dart';
import '../meal/Allergen.dart';
import '../meal/FoodType.dart';


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
  /// TODO: initialize standard-values
  FilterPreferences([
      this._categories,
      this._allergens = , /// todo: add all allergen
      this._price = 1000, // in cent
      this._rating = 0,
      this._frequency,
      this._onlyFavorite = false,
      this._sortedBy = Sorting.line,
      this._ascending = true]);

  /// returns the food categories that are displayed
  List<FoodType> get categories => _categories;

  /// TODO: do we want it like that
  /// -> do we want just set vegan, set vegetarian, set meat, ...
  set categories(List<FoodType> value) {
    _categories = value;
  }



  setCategoriesVegetarian() {
    _categories = [FoodType.vegan, FoodType.vegetarian];
  }

  setCategoriesVegan() {
    _categories = [FoodType.vegan];
  }

  /// returns the allergens that should be inside meals shown on the meal plan
  List<Allergen> get allergens => _allergens;

  /// TODO: do we just want "add allergen" and "removeAllergen"
  set allergens(List<Allergen> value) {
    _allergens = value;
  }

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

  /// TODO in more than one methods?
  set frequency(List<Frequency> value) {
    _frequency = value;
  }

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
    // TODO
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
}