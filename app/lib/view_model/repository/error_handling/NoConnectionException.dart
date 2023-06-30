/// This exception is thrown if the requested data are not stored in the local database and the connection to the server can not be established.
class NoConnectionException implements Exception {
  /// The message of the exception.
  String message;

  /// This constructor creates a new NoConnectionException with the given message.
  /// @param message The message of the exception.
  NoConnectionException(this.message);
}