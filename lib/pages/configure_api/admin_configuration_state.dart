part of 'admin_configuration_bloc.dart';

abstract class AdminConfigurationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AdminConfigurationInitial extends AdminConfigurationState {}

class AdminConfigurationLoading extends AdminConfigurationState {}

class AdminConfigurationSuccess extends AdminConfigurationState {}

class AdminConfigurationFailure extends AdminConfigurationState {
  final String error;

  AdminConfigurationFailure(this.error);

  @override
  List<Object> get props => [error];
}
