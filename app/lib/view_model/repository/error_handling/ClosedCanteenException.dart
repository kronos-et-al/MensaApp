/// This exception is thrown if the selected canteen is closed on the selected day.
class ClosedCanteenException implements Exception {
  String message;

  ClosedCanteenException(this.message);
}