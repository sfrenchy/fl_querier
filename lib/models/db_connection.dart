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
    return DBConnection(
      id: json['Id'] as int,
      name: json['Name'],
      host: '',
      port: 0,
      database: '',
      username: '',
      type: json['ConnectionType'],
      isActive: true,
      connectionString: json['ConnectionString'],
      apiRoute: json['ApiRoute'],
    );
  }
}
