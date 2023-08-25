/// This exception is thrown if the requested meal is not stored in the local database.
class ImageUploadException implements Exception {
  /// The message of the exception.
  String message;

  /// Constructor that creates a new [ImageUploadException] with the committed message.
  ImageUploadException(this.message);
}
