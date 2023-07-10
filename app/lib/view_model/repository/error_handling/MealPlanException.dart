/// This classes are exceptions that can occur by accessing or loading the meal plan.
/// This happens with functional programming.

/// This class is the superclass of al meal plan exceptions
sealed class MealPlanException implements Exception {
  /// This constructor creates a new object
  const MealPlanException();
}

/// This exception is thrown if the requested data are not stored in the local database and the connection to the server can not be established.
class NoConnectionException extends MealPlanException {
  /// The message of the exception.
  String message;

  /// This constructor creates a new NoConnectionException with the given message.
  /// @param message The message of the exception.
  NoConnectionException(this.message);
}

/// This exception is thrown if the selected canteen is closed on the selected day.
class ClosedCanteenException extends MealPlanException {
  /// The message of the exception.
  String message;

  /// This constructor creates a new ClosedCanteenException with the given message.
  /// @param message The message of the exception.
  ClosedCanteenException(this.message);
}

/// This exception is thrown if no meal of the mealplan matches the filter preferences.
class FilteredMealException extends MealPlanException {
  /// The message of the exception.
  String message;

  /// This constructor creates a new FilteredMealException with the given message.
  /// @param message The message of the exception.
  FilteredMealException(this.message);
}

/// This exception is thrown if the server does not have the requested data stored because the selected date is to far in the future or before the server started storing mealplans.
class NoDataException extends MealPlanException {
  /// The message of the exception.
  String message;

  /// This constructor creates a new NoDataException with the given message.
  /// @param message The message of the exception.
  NoDataException(this.message);
}