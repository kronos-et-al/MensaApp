/// This exception is thrown if the server does not have the requested data stored because the selected date is to far in the future or before the server started storing mealplans.
class NoDataException implements Exception {
  String message;

  NoDataException(this.message);
}