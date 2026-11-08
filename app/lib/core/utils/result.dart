import '../errors/failure.dart';

/// Minimal Result type so repositories return typed success/failure without
/// throwing across layers. Deliberately hand-rolled (no fpdart/dartz
/// dependency) to keep the pattern obvious for buyers reading the codebase.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Failed<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }

  bool get isSuccess => this is Success<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;
}
