
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/Auth Repo.dart';
import 'Auth State.dart';

class AuthCubit extends Cubit<AuthenticationState> {
  final AuthRepository authRepository;
  StreamSubscription<AuthState>? _authSubscription;

  AuthCubit({required this.authRepository}) : super(AuthInitial()) {
    _init();
  }

  void _init() {
    _authSubscription = authRepository.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        checkAuthStatus();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        emit(AuthUnauthenticated());
      }
    });
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await authRepository.signUp(
      email: email,
      password: password,
    );

    if (result.isRight) {
      emit(AuthAuthenticated(result.right!));
    } else {
      emit(AuthError(result.left!));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await authRepository.signIn(
      email: email,
      password: password,
    );

    if (result.isRight) {
      emit(AuthAuthenticated(result.right!));
    } else {
      emit(AuthError(result.left!));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await authRepository.signOut();

    if (result.isRight) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthError(result.left!));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}