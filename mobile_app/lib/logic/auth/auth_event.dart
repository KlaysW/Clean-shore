part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.nickname,
    this.isOoptStaff = false,
  });

  final String email;
  final String password;
  final String nickname;
  final bool isOoptStaff;

  @override
  List<Object?> get props => [email, password, nickname, isOoptStaff];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}