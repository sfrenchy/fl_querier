part of 'add_api_bloc.dart';

class AddApiState extends Equatable {
  final String protocol;
  final String host;
  final int port;
  final String path;

  const AddApiState({
    required this.protocol,
    required this.host,
    required this.port,
    required this.path,
  });

  factory AddApiState.initial() {
    return const AddApiState(
      protocol: 'https',
      host: '',
      port: 5000,
      path: 'api/v1',
    );
  }

  String get fullUrl => '$protocol://$host:$port/$path';

  AddApiState copyWith({
    String? protocol,
    String? host,
    int? port,
    String? path,
  }) {
    return AddApiState(
      protocol: protocol ?? this.protocol,
      host: host ?? this.host,
      port: port ?? this.port,
      path: path ?? this.path,
    );
  }

  @override
  List<Object> get props => [protocol, host, port, path];
}

class AddApiSuccess extends AddApiState {
  AddApiSuccess() : super(protocol: '', host: '', port: 0, path: '');
}

class AddApiError extends AddApiState {
  final String message;

  AddApiError(this.message) : super(protocol: '', host: '', port: 0, path: '');

  @override
  List<Object> get props => [message];
}
