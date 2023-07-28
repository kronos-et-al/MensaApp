/// These classes are responsible for error-handling.
/// This happens with functional programming.

/// This class is the superclass of all results.
sealed class Result<S, E extends Exception> {
  /// This method maps the result to a new result.
  const Result();
}

/// This class represents a success.
final class Success<S, E extends Exception> extends Result<S, E> {
  /// The value of the success.
  /// @param value The value of the success.
  const Success(this.value);

  /// The value of the success.
  final S value;
}

/// This class represents a failure.
final class Failure<S, E extends Exception> extends Result<S, E> {
  /// The value of the failure.
  /// @param value The value of the failure.
  const Failure(this.exception);

  /// The value of the failure.
  final E exception;
}
