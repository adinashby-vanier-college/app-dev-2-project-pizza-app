part of 'register_cubit.dart';

class RegisterState {
  final bool isLoading;
  final String? error;
  final bool? isSuccess;
  bool obscurePassword;

  RegisterState({
    this.obscurePassword = true,
    required this.isLoading,
    this.error,
    required this.isSuccess,
  });

  factory RegisterState.initial() {
    return RegisterState(
      isLoading: false,
      error: null,
      isSuccess: false,
      obscurePassword: true,
    );
  }

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool? obscurePassword,
    IconData? icon,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}
