part of 'databases_bloc.dart';

abstract class DatabasesEvent extends Equatable {
  const DatabasesEvent();

  @override
  List<Object> get props => [];
}

class LoadDatabases extends DatabasesEvent {}

class DeleteDatabase extends DatabasesEvent {
  final int id;

  const DeleteDatabase(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleDatabaseStatus extends DatabasesEvent {
  final int id;
  final bool isActive;

  const ToggleDatabaseStatus(this.id, this.isActive);

  @override
  List<Object> get props => [id, isActive];
}
