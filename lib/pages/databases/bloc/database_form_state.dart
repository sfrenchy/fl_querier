part of 'database_form_bloc.dart';

class DatabaseFormState extends Equatable {
  final String name;
  final String connectionString;
  final String contextApiRoute;
  final String connectionType;
  final bool generateProcedures;
  final bool isSubmitting;

  const DatabaseFormState({
    required this.name,
    required this.connectionString,
    required this.contextApiRoute,
    required this.connectionType,
    required this.generateProcedures,
    this.isSubmitting = false,
  });

  factory DatabaseFormState.initial(DBConnection? connection) {
    return DatabaseFormState(
      name: connection?.name ?? '',
      connectionString: connection?.connectionString ?? '',
      contextApiRoute: connection?.apiRoute ?? '',
      connectionType: connection?.type ?? 'MySQL',
      generateProcedures: false,
    );
  }

  DatabaseFormState copyWith({
    String? name,
    String? connectionString,
    String? contextApiRoute,
    String? connectionType,
    bool? generateProcedures,
    bool? isSubmitting,
  }) {
    return DatabaseFormState(
      name: name ?? this.name,
      connectionString: connectionString ?? this.connectionString,
      contextApiRoute: contextApiRoute ?? this.contextApiRoute,
      connectionType: connectionType ?? this.connectionType,
      generateProcedures: generateProcedures ?? this.generateProcedures,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object> get props => [
        name,
        connectionString,
        contextApiRoute,
        connectionType,
        generateProcedures,
        isSubmitting,
      ];
}

class DatabaseFormSuccess extends DatabaseFormState {
  DatabaseFormSuccess()
      : super(
          name: '',
          connectionString: '',
          contextApiRoute: '',
          connectionType: 'MySQL',
          generateProcedures: false,
        );
}

class DatabaseFormError extends DatabaseFormState {
  final String message;

  DatabaseFormError(this.message)
      : super(
          name: '',
          connectionString: '',
          contextApiRoute: '',
          connectionType: 'MySQL',
          generateProcedures: false,
        );

  @override
  List<Object> get props => [...super.props, message];
}
