import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/network/network_exceptions.dart';
import 'auth_models.dart';
import 'auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final hasSession = await _authRepository.hasValidSession();
    if (!hasSession) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final user = await _authRepository.getCurrentUser();
      emit(AuthAuthenticated(user));
    } on AppException {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.register(
        email: event.email,
        password: event.password,
        nickname: event.nickname,
        isOoptStaff: event.isOoptStaff,
      );
      emit(AuthAuthenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}