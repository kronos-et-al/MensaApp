/// This exception is thrown if the requested data are not stored in the local database and the connection to the server can not be established.
class NoConnectionException implements Exception {
  String message;

  NoConnectionException(this.message);
}