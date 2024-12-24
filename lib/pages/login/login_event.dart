part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class UrlChanged extends LoginEvent {
  final String url;

  const UrlChanged(this.url);

  @override
  List<Object?> get props => [url];
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LoadSavedUrls extends LoginEvent {}

class SetLoadingState extends LoginEvent {
  final bool isLoading;
  const SetLoadingState(this.isLoading);
  @override
  List<Object?> get props => [isLoading];
}

class SetConfigurationState extends LoginEvent {
  final bool isConfigured;
  const SetConfigurationState(this.isConfigured);
  @override
  List<Object?> get props => [isConfigured];
}

class SetError extends LoginEvent {
  final String? error;
  const SetError(this.error);
  @override
  List<Object?> get props => [error];
}

class SetAuthenticated extends LoginEvent {
  final bool isAuthenticated;
  const SetAuthenticated(this.isAuthenticated);
  @override
  List<Object?> get props => [isAuthenticated];
}

class UpdateUrlsList extends LoginEvent {
  final List<String> urls;
  const UpdateUrlsList(this.urls);
  @override
  List<Object?> get props => [urls];
}

class UpdateSelectedUrl extends LoginEvent {
  final String url;
  const UpdateSelectedUrl(this.url);
  @override
  List<Object?> get props => [url];
}
