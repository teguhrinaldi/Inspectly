import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/errors/failure.dart';

/// QC-010: error UIs must show a readable message, never
/// "Instance of 'NetworkFailure'" or a raw exception.
void main() {
  test('a Failure prints as its message', () {
    expect('${const NetworkFailure()}', const NetworkFailure().message);
  });

  test('userMessage hides raw exceptions', () {
    expect(userMessage(const TimeoutFailure()), const TimeoutFailure().message);
    expect(
      userMessage(StateError('Bad state: secret internals')),
      isNot(contains('internals')),
    );
  });
}
