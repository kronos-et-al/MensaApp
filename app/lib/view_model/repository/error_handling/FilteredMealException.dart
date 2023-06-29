/// This exception is thrown if no meal of the mealplan matches the filter preferences.
class FilteredMealException implements Exception {
  String message;

  FilteredMealException(this.message);
}