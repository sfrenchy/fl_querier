class QueryAnalysis {
  final List<String> tables;
  final List<String> views;
  final List<String> storedProcedures;
  final List<String> userFunctions;

  QueryAnalysis({
    required this.tables,
    required this.views,
    required this.storedProcedures,
    required this.userFunctions,
  });

  factory QueryAnalysis.fromJson(Map<String, dynamic> json) {
    return QueryAnalysis(
      tables: List<String>.from(json['Tables'] ?? []),
      views: List<String>.from(json['Views'] ?? []),
      storedProcedures: List<String>.from(json['StoredProcedures'] ?? []),
      userFunctions: List<String>.from(json['UserFunctions'] ?? []),
    );
  }

  @override
  String toString() => 'QueryAnalysis(tables: $tables, views: $views)';
}
