/// This exception is thrown if the requested meal is not stored in the local database.
class NoMealException implements Exception {
  /// The message of the exception.
  String message;

  /// This constructor creates a new NoMealException with the given message.
  /// @param message The message of the exception.
  NoMealException(this.message);
}