import 'package:dartz/dartz.dart';
import '../core/failures.dart';
import '../core/value_objects.dart';
import '../core/value_validators.dart';

class EmailAddress extends ValueObject<String> {
  factory EmailAddress(String input) {
    assert(input != null);
    return EmailAddress._(
      validateEmailAddress(input),
    );
  }
  const EmailAddress._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;

}

class Password extends ValueObject<String> {
  factory Password(String input) {
    assert(input != null);
    return Password._(
      validatePassword(input),
    );
  }
  const Password._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
}