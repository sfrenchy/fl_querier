import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/role.dart';

part 'roles_event.dart';
part 'roles_state.dart';

class RolesBloc extends Bloc<RolesEvent, RolesState> {
  final ApiClient _apiClient;

  RolesBloc(this._apiClient) : super(RolesInitial()) {
    on<LoadRoles>(_onLoadRoles);
  }

  Future<void> _onLoadRoles(LoadRoles event, Emitter<RolesState> emit) async {
    emit(RolesLoading());
    try {
      final roles = await _apiClient.getAllRoles();
      emit(RolesLoaded(roles));
    } catch (e) {
      emit(RolesError(e.toString()));
    }
  }
}
