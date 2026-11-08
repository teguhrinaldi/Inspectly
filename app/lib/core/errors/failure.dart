/// Human-readable failure surfaced to the UI. Never expose raw stack traces
/// or raw exception messages to the user (see spec §24).
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The request took too long. Please try again.',
  ]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has expired. Please log in again.',
  ]);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'You do not have permission to do this.',
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested item could not be found.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(
    this.fieldErrors, [
    super.message = 'Please check the information you entered.',
  ]);
  final Map<String, List<String>> fieldErrors;
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message =
        'Something went wrong on our end. Please try again shortly.',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
