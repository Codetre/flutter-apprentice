abstract class Result<T> {}

/// It models successful response
class Success<T> extends Result<T> {
  final T value;

  Success(this.value);
}

/// It models an error during HTTP call
class Error<T> extends Result<T> {
  final Exception exception;

  Error(this.exception);
}
