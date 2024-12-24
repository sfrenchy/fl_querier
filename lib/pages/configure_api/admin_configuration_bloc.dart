import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'admin_configuration_event.dart';
part 'admin_configuration_state.dart';

class AdminConfigurationBloc
    extends Bloc<AdminConfigurationEvent, AdminConfigurationState> {
  AdminConfigurationBloc() : super(AdminConfigurationInitial()) {
    on<SubmitConfigurationEvent>((event, emit) async {
      emit(AdminConfigurationLoading());
      try {
        // TODO: Implement API call
        emit(AdminConfigurationSuccess());
      } catch (e) {
        emit(AdminConfigurationFailure(e.toString()));
      }
    });
  }
}
