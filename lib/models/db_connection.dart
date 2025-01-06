class DBConnection {
  final int id;
  final String name;
  final String host;
  final int port;
  final String database;
  final String username;
  final String type;
  final bool isActive;
  final String connectionString;
  final String apiRoute;

  DBConnection({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.type,
    required this.isActive,
    required this.connectionString,
    required this.apiRoute,
  });

  factory DBConnection.fromJson(Map<String, dynamic> json) {
    final id = json['Id'];
    return DBConnection(
      id: id is int ? id : int.parse(id.toString()),
      name: json['Name'].toString(),
      host: '',
      port: 0,
      database: '',
      username: '',
      type: json['ConnectionType'].toString(),
      isActive: true,
      connectionString: json['ConnectionString'].toString(),
      apiRoute: json['ApiRoute'].toString(),
    );
  }
}

class QDBConnectionResponse {
  final int id;
  final String name;
  final String connectionType;
  final String apiRoute;

  QDBConnectionResponse({
    required this.id,
    required this.name,
    required this.connectionType,
    required this.apiRoute,
  });

  factory QDBConnectionResponse.fromJson(Map<String, dynamic> json) {
    return QDBConnectionResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      connectionType: json['connectionType'] as String,
      apiRoute: json['apiRoute'] as String,
    );
  }
}

class ControllerInfoResponse {
  final String name;
  final String route;
  final String? httpGetJsonSchema;

  ControllerInfoResponse({
    required this.name,
    required this.route,
    this.httpGetJsonSchema,
  });

  factory ControllerInfoResponse.fromJson(Map<String, dynamic> json) {
    return ControllerInfoResponse(
      name: json['Name'] as String,
      route: json['Route'] as String,
      httpGetJsonSchema: json['HttpGetJsonSchema'] as String?,
    );
  }
}
