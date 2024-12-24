import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'add_api_event.dart';
part 'add_api_state.dart';

class AddApiBloc extends Bloc<AddApiEvent, AddApiState> {
  AddApiBloc() : super(AddApiState.initial()) {
    on<ProtocolChanged>(_onProtocolChanged);
    on<HostChanged>(_onHostChanged);
    on<PortChanged>(_onPortChanged);
    on<PathChanged>(_onPathChanged);
    on<SaveApiUrl>(_onSaveApiUrl);
  }

  void _onProtocolChanged(ProtocolChanged event, Emitter<AddApiState> emit) {
    emit(state.copyWith(protocol: event.protocol));
  }

  void _onHostChanged(HostChanged event, Emitter<AddApiState> emit) {
    emit(state.copyWith(host: event.host));
  }

  void _onPortChanged(PortChanged event, Emitter<AddApiState> emit) {
    emit(state.copyWith(port: event.port));
  }

  void _onPathChanged(PathChanged event, Emitter<AddApiState> emit) {
    emit(state.copyWith(path: event.path));
  }

  Future<void> _onSaveApiUrl(
      SaveApiUrl event, Emitter<AddApiState> emit) async {
    if (state.host.isEmpty || state.port == 0 || state.path.isEmpty) {
      emit(AddApiError('Please fill in all fields'));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final urls = prefs.getStringList('APIURLS') ?? [];

      if (!urls.contains(state.fullUrl)) {
        urls.add(state.fullUrl);
        await prefs.setStringList('APIURLS', urls);
        emit(AddApiSuccess());
      } else {
        emit(AddApiError('This API URL already exists'));
      }
    } catch (e) {
      emit(AddApiError(e.toString()));
    }
  }
}
