class SQLParser {
  final String query;

  SQLParser(this.query);

  List<String> extractTables() {
    final tables = <String>[];

    // Extraire la partie FROM et les JOINs de la requête
    final fromAndJoins = RegExp(
          r'FROM\s+(.*?)(?:WHERE|ORDER BY|GROUP BY|$)',
          caseSensitive: false,
          multiLine: true,
          dotAll: true,
        ).firstMatch(query)?.group(1)?.trim() ??
        '';

    // Expression régulière pour capturer :
    // 1. Les noms de tables entre guillemets
    // 2. Les noms de tables simples
    // 3. Les tables dans les clauses JOIN
    final tablePattern = RegExp(
      r'(?:FROM|JOIN)\s+(?:"([^"]+)"|\`([^\`]+)\`|([a-zA-Z_][a-zA-Z0-9_]*))',
      caseSensitive: false,
      multiLine: true,
    );

    final matches = tablePattern.allMatches(fromAndJoins);

    for (final match in matches) {
      // Prendre le premier groupe non-null (soit le nom entre guillemets, soit le nom simple)
      final tableName = match.group(1) ?? match.group(2) ?? match.group(3);
      if (tableName != null && !tables.contains(tableName)) {
        tables.add(tableName);
      }
    }

    return tables;
  }
}
