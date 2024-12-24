import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/dynamic_row.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiClient _apiClient;

  HomeBloc(this._apiClient) : super(HomeInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final userData = await _apiClient.getCurrentUser();
      final recentQueries = await _apiClient.getRecentQueries();
      final stats = await _apiClient.getQueryStats();
      final activity = await _apiClient.getActivityData();

      // Charger le layout de la page d'accueil (assumons que l'ID est 1)
      final layout = await _apiClient.getLayout(event.pageId);
      final rows = layout.rows;

      emit(HomeLoaded(
        email: userData.data['email'] ?? '',
        firstName: userData.data['FirstName'] ?? '',
        lastName: userData.data['LastName'] ?? '',
        recentQueries: List<String>.from(recentQueries),
        queryStats: Map<String, int>.from(stats),
        activityData: List<Map<String, dynamic>>.from(activity),
        rows: rows,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
      RefreshDashboard event, Emitter<HomeState> emit) async {
    try {
      if (state is HomeLoaded) {
        final userData = await _apiClient.getCurrentUser();
        final recentQueries = await _apiClient.getRecentQueries();
        final stats = await _apiClient.getQueryStats();
        final activity = await _apiClient.getActivityData();

        emit(HomeLoaded(
          email: userData.data['email'] ?? '',
          firstName: userData.data['FirstName'] ?? '',
          lastName: userData.data['LastName'] ?? '',
          recentQueries: List<String>.from(recentQueries),
          queryStats: Map<String, int>.from(stats),
          activityData: List<Map<String, dynamic>>.from(activity),
          rows: [],
        ));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<HomeState> emit) async {
    await _apiClient.logout();
  }
}
