import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/menu_category.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final ApiClient _apiClient;

  MenuBloc(this._apiClient) : super(MenuInitial()) {
    on<LoadMenu>(_onLoadMenu);
  }

  Future<void> _onLoadMenu(LoadMenu event, Emitter<MenuState> emit) async {
    print('Loading menu...'); // Debug
    emit(MenuLoading());
    try {
      final categories = await _apiClient.getMenuCategories();
      print('Got ${categories.length} categories from API'); // Debug
      final List<MenuCategory> categoriesWithPages = [];
      for (var category in categories) {
        final pages = await _apiClient.getPages(category.Id);
        categoriesWithPages.add(MenuCategory(
          Id: category.Id,
          names: category.names,
          icon: category.icon,
          order: category.order,
          isVisible: category.isVisible,
          roles: category.roles,
          route: category.route,
          pages: pages,
        ));
      }
      print(
          'Categories with pages: ${categoriesWithPages.map((c) => '${c.names} (${c.pages.length} pages)')}');
      emit(MenuLoaded(categoriesWithPages));
    } catch (e) {
      print('Error loading menu: $e');
      emit(MenuError(e.toString()));
    }
  }
}
