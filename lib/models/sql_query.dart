import 'package:querier/models/db_connection.dart';

extension StringX on String {
  DateTime? toDateTime() {
    try {
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }
}

class SQLQuery {
  final int id;
  final String name;
  final String description;
  final String query;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final bool isPublic;
  final Map<String, dynamic> parameters;
  final int? connectionId;
  final DBConnection? connection;
  final String? outputDescription;

  SQLQuery({
    required this.id,
    required this.name,
    required this.description,
    required this.query,
    required this.createdBy,
    required this.createdAt,
    this.lastModifiedAt,
    required this.isPublic,
    required this.parameters,
    this.connectionId,
    this.connection,
    this.outputDescription,
  });

  factory SQLQuery.fromJson(Map<String, dynamic> json) {
    print('Parsing SQLQuery JSON: $json');
    try {
      final id = json['Id'] ?? json['id'];
      final connectionId = json['ConnectionId'] ?? json['connectionId'];
      final connection = json['Connection'];
      final createdAt = json['CreatedAt'] ?? json['createdAt'];
      final lastModifiedAt = json['LastModifiedAt'] ?? json['lastModifiedAt'];

      return SQLQuery(
        id: id is int ? id : int.parse(id?.toString() ?? '0'),
        name: json['Name']?.toString() ?? json['name']?.toString() ?? '',
        description: json['Description']?.toString() ??
            json['description']?.toString() ??
            '',
        query: json['Query']?.toString() ?? json['query']?.toString() ?? '',
        createdBy: (json['CreatedBy'] ?? json['createdBy'] ?? '').toString(),
        createdAt: createdAt is DateTime
            ? createdAt
            : DateTime.parse(createdAt.toString()),
        lastModifiedAt: lastModifiedAt != null
            ? lastModifiedAt is DateTime
                ? lastModifiedAt
                : DateTime.parse(lastModifiedAt.toString())
            : null,
        isPublic: json['IsPublic'] ?? json['isPublic'] ?? false,
        parameters: Map<String, dynamic>.from(
            json['Parameters'] ?? json['parameters'] ?? {}),
        connectionId: connectionId is int
            ? connectionId
            : connectionId != null
                ? int.parse(connectionId.toString())
                : null,
        connection: connection != null
            ? DBConnection.fromJson(Map<String, dynamic>.from(connection))
            : null,
        outputDescription: json['OutputDescription']?.toString() ?? json['outputDescription']?.toString(),
      );
    } catch (e, stackTrace) {
      print('Error parsing SQLQuery: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Name': name,
        'Description': description,
        'Query': query,
        'CreatedBy': createdBy,
        'CreatedAt': createdAt.toIso8601String(),
        'LastModifiedAt': lastModifiedAt?.toIso8601String(),
        'IsPublic': isPublic,
        'Parameters': parameters,
        'ConnectionId': connectionId,
        'OutputDescription': outputDescription,
      };
}
