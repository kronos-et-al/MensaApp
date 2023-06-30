/// This exception is thrown if no meal of the mealplan matches the filter preferences.
class FilteredMealException implements Exception {
  /// The message of the exception.
  String message;

  /// This constructor creates a new FilteredMealException with the given message.
  /// @param message The message of the exception.
  FilteredMealException(this.message);
}