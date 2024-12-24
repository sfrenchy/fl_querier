import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:querier/api/api_client.dart';
import 'queries_event.dart';
import 'queries_state.dart';

class QueriesBloc extends Bloc<QueriesEvent, QueriesState> {
  final ApiClient _apiClient;

  QueriesBloc(this._apiClient) : super(QueriesInitial()) {
    on<LoadQueries>(_onLoadQueries);
    on<DeleteQuery>(_onDeleteQuery);
    on<AddQuery>(_onAddQuery);
    on<UpdateQuery>(_onUpdateQuery);
  }

  Future<void> _onLoadQueries(
    LoadQueries event,
    Emitter<QueriesState> emit,
  ) async {
    emit(QueriesLoading());
    try {
      final queries = await _apiClient.getSQLQueries();
      emit(QueriesLoaded(queries));
    } catch (e) {
      emit(QueriesError(e.toString()));
    }
  }

  Future<void> _onDeleteQuery(
    DeleteQuery event,
    Emitter<QueriesState> emit,
  ) async {
    try {
      await _apiClient.deleteSQLQuery(event.queryId);
      add(LoadQueries()); // Recharger la liste après suppression
    } catch (e) {
      emit(QueriesError(e.toString()));
    }
  }

  Future<void> _onAddQuery(
    AddQuery event,
    Emitter<QueriesState> emit,
  ) async {
    try {
      print('AddQuery event: ${event.sampleParameters}'); // Debug log
      await _apiClient.createSQLQuery(
        event.query,
        sampleParameters: event.sampleParameters,
      );
      add(LoadQueries());
    } catch (e) {
      emit(QueriesError(e.toString()));
    }
  }

  Future<void> _onUpdateQuery(
    UpdateQuery event,
    Emitter<QueriesState> emit,
  ) async {
    try {
      print('UpdateQuery event: ${event.sampleParameters}'); // Debug log
      await _apiClient.updateSQLQuery(
        event.query.id,
        event.query,
        sampleParameters: event.sampleParameters,
      );
      add(LoadQueries());
    } catch (e) {
      emit(QueriesError(e.toString()));
    }
  }
}
