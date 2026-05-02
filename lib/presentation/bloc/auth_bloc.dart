import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/user.dart';

/// EVENTS

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {

  final String username;
  final String password;

  LoginRequested(this.username, this.password);
}

class LogoutRequested extends AuthEvent {}

/// STATE

class AuthState {

  final User? user;
  final bool loading;
  final String? error;

  const AuthState({
    this.user,
    this.loading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// BLOC

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final AuthService authService;

  AuthBloc(this.authService)
      : super(const AuthState()) {

    on<LoginRequested>(_onLoginRequested);

    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {

    emit(state.copyWith(
      loading: true,
      error: null,
    ));

    final user = await authService.login(
      event.username,
      event.password,
    );

    if (user == null) {

      emit(state.copyWith(
        loading: false,
        error: "Invalid credentials",
      ));

    } else {

      emit(state.copyWith(
        loading: false,
        user: user,
      ));
    }
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {

    authService.logout();

    emit(const AuthState());
  }
}