import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import '../../../domain/auth/auth_failure.dart';
import '../../../domain/auth/i_auth_facade.dart';
import '../../../domain/auth/value_objects.dart';

part 'sign_in_form_bloc.freezed.dart';
part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';

@injectable
class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  SignInFormBloc(this._authFacade) : super(SignInFormState.initial());

  final IAuthFacade _authFacade;

  @override
  Stream<SignInFormState> mapEventToState(
      SignInFormEvent event,
      ) async* {
    yield* event.map(
      emailChanged: (EmailChanged e) async* {
        yield state.copyWith(
          emailAddress: EmailAddress(e.emailStr),
          authFailureOrSuccessOption: none(),
        );
      },
      passwordChanged: (PasswordChanged e) async* {
        yield state.copyWith(
          password: Password(e.passwordStr),
          authFailureOrSuccessOption: none(),
        );
      },
      registerWithEmailAndPasswordPressed: (RegisterWithEmailAndPasswordPressed e) async* {
        yield* _performActionOnAuthFacadeWithEmailAndPassword(
          _authFacade.registerWithEmailAndPassword,
        );
      },
      signInWithEmailAndPasswordPressed: (SignInWithEmailAndPasswordPressed e) async* {
        yield* _performActionOnAuthFacadeWithEmailAndPassword(
          _authFacade.signInWithEmailAndPassword,
        );
      },
      signInWithGooglePressed: (SignInWithGooglePressed e) async* {
        yield state.copyWith(
          isSubmitting: true,
          authFailureOrSuccessOption: none(),
        );
        final Either<AuthFailure, Unit> failureOrSuccess = await _authFacade.signInWithGoogle();
        yield state.copyWith(
          isSubmitting: false,
          authFailureOrSuccessOption: some(failureOrSuccess),
        );
      },
    );
  }

  Stream<SignInFormState> _performActionOnAuthFacadeWithEmailAndPassword(
  Future<Either<AuthFailure, Unit>> Function({
    @required EmailAddress emailAddress,
    @required Password password,
  })
  forwardedCall,
  ) async* {
  Either<AuthFailure, Unit> failureOrSuccess;

  final bool isEmailValid = state.emailAddress.isValid();
  final bool isPasswordValid = state.password.isValid();

  if (isEmailValid && isPasswordValid) {
  yield state.copyWith(
  isSubmitting: true,
  authFailureOrSuccessOption: none(),
  );

  failureOrSuccess = await forwardedCall(
  emailAddress: state.emailAddress,
  password: state.password,
  );
  }

  yield state.copyWith(
  isSubmitting: false,
  showErrorMessages: true,
  authFailureOrSuccessOption: optionOf(failureOrSuccess),
  );
  }
}