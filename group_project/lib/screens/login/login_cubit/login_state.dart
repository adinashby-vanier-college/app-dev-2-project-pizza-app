part of 'login_cubit.dart';

class LoginState {
  bool obscurePassword;

  LoginState({
    this.obscurePassword = true,
  });

  factory LoginState.initial() {
    return LoginState(
      obscurePassword: true,
    );
  }

  LoginState copyWith({
    bool? obscurePassword,
  }) {
    return LoginState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}
