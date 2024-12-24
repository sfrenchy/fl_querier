part of 'smtp_configuration_bloc.dart';

abstract class SmtpConfigurationEvent extends Equatable {
  const SmtpConfigurationEvent();

  @override
  List<Object> get props => [];
}

class SubmitSmtpConfigurationEvent extends SmtpConfigurationEvent {
  final String adminName;
  final String adminFirstName;
  final String adminEmail;
  final String adminPassword;
  final String apiUrl;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool useSSL;
  final String senderEmail;
  final String senderName;
  final bool requireAuth;

  const SubmitSmtpConfigurationEvent({
    required this.adminName,
    required this.adminFirstName,
    required this.adminEmail,
    required this.adminPassword,
    required this.apiUrl,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.useSSL,
    required this.senderEmail,
    required this.senderName,
    required this.requireAuth,
  });

  @override
  List<Object> get props => [
        adminName,
        adminFirstName,
        adminEmail,
        adminPassword,
        apiUrl,
        host,
        port,
        username,
        password,
        useSSL,
        senderEmail,
        senderName,
        requireAuth,
      ];
}
