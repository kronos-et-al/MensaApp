/// These classes are responsible for error-handling.
/// This happens with functional programming.


/// This class is the superclass of all results.
sealed class Result<S, E extends Exception> {
  /// Constructor that maps the result to a new result.
  const Result();
}

/// This class represents a success.
final class Success<S, E extends Exception> extends Result<S, E> {
  /// Constructor that creates a new [Success] with the committed value of Type [S].
  const Success(this.value);

  /// The value of the success.
  final S value;
}

/// This class represents a failure.
final class Failure<S, E extends Exception> extends Result<S, E> {
  /// Constructor that creates a new [Failure] with the committed [Exception] of Type [S].
  const Failure(this.exception);

  /// The value of the failure.
  final E exception;
}
