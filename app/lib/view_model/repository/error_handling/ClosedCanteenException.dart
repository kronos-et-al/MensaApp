/// This exception is thrown if the selected canteen is closed on the selected day.
class ClosedCanteenException implements Exception {
  /// The message of the exception.
  String message;

  /// This constructor creates a new ClosedCanteenException with the given message.
  /// @param message The message of the exception.
  ClosedCanteenException(this.message);
}