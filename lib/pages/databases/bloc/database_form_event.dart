part of 'database_form_bloc.dart';

abstract class DatabaseFormEvent extends Equatable {
  const DatabaseFormEvent();

  @override
  List<Object> get props => [];
}

class NameChanged extends DatabaseFormEvent {
  final String name;
  const NameChanged(this.name);

  @override
  List<Object> get props => [name];
}

class ConnectionStringChanged extends DatabaseFormEvent {
  final String connectionString;
  const ConnectionStringChanged(this.connectionString);

  @override
  List<Object> get props => [connectionString];
}

class ApiRouteChanged extends DatabaseFormEvent {
  final String apiRoute;
  const ApiRouteChanged(this.apiRoute);

  @override
  List<Object> get props => [apiRoute];
}

class ConnectionTypeChanged extends DatabaseFormEvent {
  final String connectionType;
  const ConnectionTypeChanged(this.connectionType);

  @override
  List<Object> get props => [connectionType];
}

class GenerateProceduresChanged extends DatabaseFormEvent {
  final bool generateProcedures;
  const GenerateProceduresChanged(this.generateProcedures);

  @override
  List<Object> get props => [generateProcedures];
}

class FormSubmitted extends DatabaseFormEvent {}
