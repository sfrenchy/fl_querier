import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/api/api_endpoints.dart';
import 'package:querier/models/db_connection.dart';

part 'databases_event.dart';
part 'databases_state.dart';

class DatabasesBloc extends Bloc<DatabasesEvent, DatabasesState> {
  final ApiClient _apiClient;

  DatabasesBloc(this._apiClient) : super(DatabasesInitial()) {
    on<LoadDatabases>(_onLoadDatabases);
    on<DeleteDatabase>(_onDeleteDatabase);
    on<ToggleDatabaseStatus>(_onToggleDatabaseStatus);
  }

  Future<void> _onLoadDatabases(
      LoadDatabases event, Emitter<DatabasesState> emit) async {
    emit(DatabasesLoading());
    try {
      final connections = await _apiClient.getDBConnections();
      emit(DatabasesLoaded(connections));
    } catch (e) {
      emit(DatabasesError(e.toString()));
    }
  }

  Future<void> _onDeleteDatabase(
      DeleteDatabase event, Emitter<DatabasesState> emit) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.deleteDbConnection,
        data: {'dbConnectionId': event.id},
      );
      add(LoadDatabases());
    } catch (e) {
      emit(DatabasesError(e.toString()));
    }
  }

  Future<void> _onToggleDatabaseStatus(
      ToggleDatabaseStatus event, Emitter<DatabasesState> emit) async {
    try {
      await _apiClient.put(
        ApiEndpoints.replaceUrlParams(
            ApiEndpoints.updateDbConnection, {'id': event.id.toString()}),
        data: {'isActive': event.isActive},
      );
      add(LoadDatabases());
    } catch (e) {
      emit(DatabasesError(e.toString()));
    }
  }
}
