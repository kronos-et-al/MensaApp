/// These classes are responsible for error-handling.
/// This happens with functional programming.

/// This class is the superclass of all results.
sealed class Result<S> {
  /// This method maps the result to a new result.
  const Result();
}

/// This class represents a success.
final class Success<S> extends Result<S> {
  /// The value of the success.
  /// @param value The value of the success.
  const Success(this.value);

  /// The value of the success.
  final S value;
}

/// This class represents a failure.
final class Failure<S> extends Result<S> {
  /// The value of the failure.
  /// @param value The value of the failure.
  const Failure(this.value);

  /// The value of the failure.
  final Exception value;
}

