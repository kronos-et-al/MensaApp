/// This exception is thrown if the requested meal is not stored in the local database.
class NoMealException implements Exception {
  String message;

  NoMealException(this.message);
}