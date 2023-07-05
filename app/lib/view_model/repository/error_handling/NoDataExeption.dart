/// This exception is thrown if the server does not have the requested data stored because the selected date is to far in the future or before the server started storing mealplans.
class NoDataException implements Exception {
  /// The message of the exception.
  String message;

  /// This constructor creates a new NoDataException with the given message.
  /// @param message The message of the exception.
  NoDataException(this.message);
}