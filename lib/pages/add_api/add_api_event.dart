part of 'add_api_bloc.dart';

abstract class AddApiEvent extends Equatable {
  const AddApiEvent();

  @override
  List<Object?> get props => [];
}

class ProtocolChanged extends AddApiEvent {
  final String protocol;
  const ProtocolChanged(this.protocol);
  @override
  List<Object?> get props => [protocol];
}

class HostChanged extends AddApiEvent {
  final String host;
  const HostChanged(this.host);
  @override
  List<Object?> get props => [host];
}

class PortChanged extends AddApiEvent {
  final int port;
  const PortChanged(this.port);
  @override
  List<Object?> get props => [port];
}

class PathChanged extends AddApiEvent {
  final String path;
  const PathChanged(this.path);
  @override
  List<Object?> get props => [path];
}

class SaveApiUrl extends AddApiEvent {}
