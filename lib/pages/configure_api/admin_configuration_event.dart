part of 'admin_configuration_bloc.dart';

abstract class AdminConfigurationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SubmitConfigurationEvent extends AdminConfigurationEvent {
  final String name;
  final String firstName;
  final String email;
  final String password;

  SubmitConfigurationEvent({
    required this.name,
    required this.firstName,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, firstName, email, password];
}
