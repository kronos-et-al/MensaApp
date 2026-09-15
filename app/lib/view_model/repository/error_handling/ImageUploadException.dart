/// This exception is thrown if the image upload fails.
class ImageUploadException implements Exception {
  /// The localized message key of the exception.
  final String message;

  /// The full raw error message or stack trace for debugging.
  final String? rawError;

  /// Constructor that creates a new [ImageUploadException] with the committed message and optional raw error.
  ImageUploadException(this.message, [this.rawError]);

  @override
  String toString() => rawError != null ? "$message ($rawError)" : message;
}
