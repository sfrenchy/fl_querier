part of 'databases_bloc.dart';

abstract class DatabasesState extends Equatable {
  const DatabasesState();

  @override
  List<Object> get props => [];
}

class DatabasesInitial extends DatabasesState {}

class DatabasesLoading extends DatabasesState {}

class DatabasesLoaded extends DatabasesState {
  final List<DBConnection> connections;

  const DatabasesLoaded(this.connections);

  @override
  List<Object> get props => [connections];
}

class DatabasesError extends DatabasesState {
  final String message;

  const DatabasesError(this.message);

  @override
  List<Object> get props => [message];
}
