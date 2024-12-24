part of 'roles_bloc.dart';

abstract class RolesState extends Equatable {
  const RolesState();

  @override
  List<Object> get props => [];
}

class RolesInitial extends RolesState {}

class RolesLoading extends RolesState {}

class RolesLoaded extends RolesState {
  final List<Role> roles;

  const RolesLoaded(this.roles);

  @override
  List<Object> get props => [roles];
}

class RolesError extends RolesState {
  final String message;

  const RolesError(this.message);

  @override
  List<Object> get props => [message];
}
