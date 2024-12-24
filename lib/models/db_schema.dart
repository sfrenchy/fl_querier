class DatabaseSchema {
  final List<TableDescription> tables;
  final List<ViewDescription> views;
  final List<StoredProcedureDescription> storedProcedures;
  final List<UserFunctionDescription> userFunctions;

  DatabaseSchema({
    required this.tables,
    required this.views,
    required this.storedProcedures,
    required this.userFunctions,
  });

  factory DatabaseSchema.fromJson(Map<String, dynamic> json) {
    return DatabaseSchema(
      tables: (json['Tables'] as List?)
              ?.map((x) => TableDescription.fromJson(x))
              .toList() ??
          [],
      views: (json['Views'] as List?)
              ?.map((x) => ViewDescription.fromJson(x))
              .toList() ??
          [],
      storedProcedures: (json['StoredProcedures'] as List?)
              ?.map((x) => StoredProcedureDescription.fromJson(x))
              .toList() ??
          [],
      userFunctions: (json['UserFunctions'] as List?)
              ?.map((x) => UserFunctionDescription.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class TableDescription {
  final String name;
  final String schema;
  final List<ColumnDescription> columns;

  TableDescription({
    required this.name,
    required this.schema,
    required this.columns,
  });

  factory TableDescription.fromJson(Map<String, dynamic> json) {
    return TableDescription(
      name: json['Name'] ?? '',
      schema: json['Schema'] ?? '',
      columns: (json['Columns'] as List?)
              ?.map((x) => ColumnDescription.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class ViewDescription {
  final String name;
  final String schema;
  final List<ColumnDescription> columns;

  ViewDescription({
    required this.name,
    required this.schema,
    required this.columns,
  });

  factory ViewDescription.fromJson(Map<String, dynamic> json) {
    return ViewDescription(
      name: json['Name'] ?? '',
      schema: json['Schema'] ?? '',
      columns: (json['Columns'] as List?)
              ?.map((x) => ColumnDescription.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class ColumnDescription {
  final String name;
  final String dataType;
  final bool isNullable;
  final bool isPrimaryKey;
  final bool isForeignKey;
  final String? foreignKeyTable;
  final String? foreignKeyColumn;

  ColumnDescription({
    required this.name,
    required this.dataType,
    required this.isNullable,
    required this.isPrimaryKey,
    required this.isForeignKey,
    this.foreignKeyTable,
    this.foreignKeyColumn,
  });

  factory ColumnDescription.fromJson(Map<String, dynamic> json) {
    return ColumnDescription(
      name: json['Name'] ?? '',
      dataType: json['DataType'] ?? '',
      isNullable: json['IsNullable'] ?? false,
      isPrimaryKey: json['IsPrimaryKey'] ?? false,
      isForeignKey: json['IsForeignKey'] ?? false,
      foreignKeyTable: json['ForeignKeyTable'],
      foreignKeyColumn: json['ForeignKeyColumn'],
    );
  }
}

class StoredProcedureDescription {
  final String name;
  final String schema;
  final List<ParameterDescription> parameters;

  StoredProcedureDescription({
    required this.name,
    required this.schema,
    required this.parameters,
  });

  factory StoredProcedureDescription.fromJson(Map<String, dynamic> json) {
    return StoredProcedureDescription(
      name: json['Name'] ?? '',
      schema: json['Schema'] ?? '',
      parameters: (json['Parameters'] as List?)
              ?.map((x) => ParameterDescription.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class UserFunctionDescription {
  final String name;
  final String schema;
  final List<ParameterDescription> parameters;
  final String? returnType;

  UserFunctionDescription({
    required this.name,
    required this.schema,
    required this.parameters,
    this.returnType,
  });

  factory UserFunctionDescription.fromJson(Map<String, dynamic> json) {
    return UserFunctionDescription(
      name: json['Name'] ?? '',
      schema: json['Schema'] ?? '',
      parameters: (json['Parameters'] as List?)
              ?.map((x) => ParameterDescription.fromJson(x))
              .toList() ??
          [],
      returnType: json['ReturnType'],
    );
  }
}

class ParameterDescription {
  final String name;
  final String dataType;
  final String mode;

  ParameterDescription({
    required this.name,
    required this.dataType,
    required this.mode,
  });

  factory ParameterDescription.fromJson(Map<String, dynamic> json) {
    return ParameterDescription(
      name: json['Name'] ?? '',
      dataType: json['DataType'] ?? '',
      mode: json['Mode'] ?? '',
    );
  }
}
