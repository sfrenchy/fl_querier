class AddDBConnectionRequest {
  final String name;
  final String connectionString;
  final String contextApiRoute;
  final String connectionType;
  final bool generateProcedureControllersAndServices;

  AddDBConnectionRequest({
    required this.name,
    required this.connectionString,
    required this.contextApiRoute,
    required this.connectionType,
    this.generateProcedureControllersAndServices = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'connectionString': connectionString,
        'contextApiRoute': contextApiRoute,
        'connectionType': _mapConnectionType(connectionType),
        'generateProcedureControllersAndServices':
            generateProcedureControllersAndServices,
      };

  int _mapConnectionType(String type) {
    switch (type) {
      case 'SqlServer':
        return 0; // QDBConnectionType.SqlServer
      case 'MySQL':
        return 1; // QDBConnectionType.MySQL
      case 'PgSQL':
        return 2; // QDBConnectionType.PgSQL
      default:
        return 0; // SqlServer par défaut
    }
  }
}
