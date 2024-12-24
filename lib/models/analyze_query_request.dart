class AnalyzeQueryRequest {
  final String query;
  final Map<String, dynamic> parameters;

  AnalyzeQueryRequest({
    required this.query,
    this.parameters = const {},
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'parameters': parameters,
      };
}
