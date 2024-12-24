import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:querier/services/wizard_service.dart';
import 'package:querier/api/api_client.dart';

part 'smtp_configuration_event.dart';
part 'smtp_configuration_state.dart';

class SmtpConfigurationBloc
    extends Bloc<SmtpConfigurationEvent, SmtpConfigurationState> {
  final WizardService _wizardService;
  final ApiClient _apiClient;

  SmtpConfigurationBloc(String baseUrl, NavigatorState navigator)
      : _wizardService = WizardService(baseUrl, navigator),
        _apiClient = ApiClient(baseUrl, navigator),
        super(SmtpConfigurationInitial()) {
    on<SubmitSmtpConfigurationEvent>((event, emit) async {
      emit(SmtpConfigurationLoading());
      try {
        final success = await _wizardService.setup(
          name: event.adminName,
          firstName: event.adminFirstName,
          email: event.adminEmail,
          password: event.adminPassword,
          smtpHost: event.host,
          smtpPort: event.port,
          smtpUsername: event.username,
          smtpPassword: event.password,
          useSSL: event.useSSL,
          senderEmail: event.senderEmail,
          senderName: event.senderName,
        );

        if (success) {
          try {
            final response = await _apiClient.signIn(
              event.adminEmail,
              event.adminPassword,
            );

            if (response.statusCode == 200) {
              emit(SmtpConfigurationSuccessWithAuth(response.data));
            } else {
              emit(SmtpConfigurationSuccess());
            }
          } catch (authError) {
            emit(SmtpConfigurationSuccess());
          }
        } else {
          emit(SmtpConfigurationFailure('Setup failed'));
        }
      } catch (e) {
        emit(SmtpConfigurationFailure(e.toString()));
      }
    });
  }
}

class TestSmtpConfigurationEvent extends SmtpConfigurationEvent {
  final String host;
  final int port;
  final String username;
  final String password;
  final String senderEmail;
  final String senderName;
  final bool useSsl;

  const TestSmtpConfigurationEvent({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.senderEmail,
    required this.senderName,
    required this.useSsl,
  });

  @override
  List<Object> get props =>
      [host, port, username, password, senderEmail, senderName, useSsl];
}
