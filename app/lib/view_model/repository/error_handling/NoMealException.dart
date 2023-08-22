/// This exception is thrown if the requested meal is not stored in the local database.
class NoMealException implements Exception {
  /// The message of the exception.
  String message;

  /// Constructor that creates a new [NoMealException] with the committed message.
  NoMealException(this.message);
}
