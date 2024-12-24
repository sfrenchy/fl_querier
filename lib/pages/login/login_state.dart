part of 'login_bloc.dart';

class LoginState extends Equatable {
  final List<String> urls;
  final String selectedUrl;
  final bool isConfigured;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const LoginState({
    this.urls = const [],
    this.selectedUrl = '',
    this.isConfigured = false,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  LoginState copyWith({
    List<String>? urls,
    String? selectedUrl,
    bool? isConfigured,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return LoginState(
      urls: urls ?? this.urls,
      selectedUrl: selectedUrl ?? this.selectedUrl,
      isConfigured: isConfigured ?? this.isConfigured,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        urls,
        selectedUrl,
        isConfigured,
        isLoading,
        isAuthenticated,
        error,
      ];
}
