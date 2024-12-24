part of 'smtp_configuration_bloc.dart';

abstract class SmtpConfigurationState extends Equatable {
  const SmtpConfigurationState();

  @override
  List<Object> get props => [];
}

class SmtpConfigurationInitial extends SmtpConfigurationState {}

class SmtpConfigurationLoading extends SmtpConfigurationState {}

class SmtpConfigurationSuccess extends SmtpConfigurationState {}

class SmtpConfigurationFailure extends SmtpConfigurationState {
  final String error;
  const SmtpConfigurationFailure(this.error);
  @override
  List<Object> get props => [error];
}

// Ajout des états pour le test SMTP
class SmtpTestLoading extends SmtpConfigurationState {}

class SmtpTestSuccess extends SmtpConfigurationState {}

class SmtpTestFailure extends SmtpConfigurationState {
  final String error;
  const SmtpTestFailure(this.error);
  @override
  List<Object> get props => [error];
}

class SmtpConfigurationSuccessWithAuth extends SmtpConfigurationState {
  final Map<String, dynamic> authResponse;

  const SmtpConfigurationSuccessWithAuth(this.authResponse);

  @override
  List<Object> get props => [authResponse];
}
