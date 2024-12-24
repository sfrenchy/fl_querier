import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/api/api_endpoints.dart';
import 'package:querier/models/db_connection.dart';
import 'package:querier/models/requests/add_db_connection_request.dart';

part 'database_form_event.dart';
part 'database_form_state.dart';

class DatabaseFormBloc extends Bloc<DatabaseFormEvent, DatabaseFormState> {
  final ApiClient _apiClient;
  final DBConnection? connectionToEdit;

  DatabaseFormBloc(this._apiClient, {this.connectionToEdit})
      : super(DatabaseFormState.initial(connectionToEdit)) {
    on<NameChanged>(_onNameChanged);
    on<ConnectionStringChanged>(_onConnectionStringChanged);
    on<ApiRouteChanged>(_onApiRouteChanged);
    on<ConnectionTypeChanged>(_onConnectionTypeChanged);
    on<GenerateProceduresChanged>(_onGenerateProceduresChanged);
    on<FormSubmitted>(_onSubmitted);
  }

  void _onNameChanged(NameChanged event, Emitter<DatabaseFormState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onConnectionStringChanged(
      ConnectionStringChanged event, Emitter<DatabaseFormState> emit) {
    emit(state.copyWith(connectionString: event.connectionString));
  }

  void _onApiRouteChanged(
      ApiRouteChanged event, Emitter<DatabaseFormState> emit) {
    emit(state.copyWith(contextApiRoute: event.apiRoute));
  }

  void _onConnectionTypeChanged(
      ConnectionTypeChanged event, Emitter<DatabaseFormState> emit) {
    emit(state.copyWith(connectionType: event.connectionType));
  }

  void _onGenerateProceduresChanged(
      GenerateProceduresChanged event, Emitter<DatabaseFormState> emit) {
    emit(state.copyWith(generateProcedures: event.generateProcedures));
  }

  Future<void> _onSubmitted(
      FormSubmitted event, Emitter<DatabaseFormState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final request = AddDBConnectionRequest(
        name: state.name,
        connectionString: state.connectionString,
        contextApiRoute: state.contextApiRoute,
        connectionType: state.connectionType,
        generateProcedureControllersAndServices: state.generateProcedures,
      );

      await _apiClient.post(ApiEndpoints.addDbConnection,
          data: request.toJson());
      emit(DatabaseFormSuccess());
    } catch (e) {
      emit(DatabaseFormError(e.toString()));
    }
  }
}
