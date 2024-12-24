import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/blocs/menu_bloc.dart';
import 'package:querier/models/menu_category.dart';

part 'dynamic_menu_categories_event.dart';
part 'dynamic_menu_categories_state.dart';

class DynamicMenuCategoriesBloc
    extends Bloc<DynamicMenuCategoriesEvent, DynamicMenuCategoriesState> {
  final ApiClient _apiClient;
  final BuildContext context;

  DynamicMenuCategoriesBloc(this._apiClient, this.context)
      : super(DynamicMenuCategoriesInitial()) {
    on<LoadDynamicMenuCategories>(_onLoadDynamicMenuCategories);
    on<DeleteDynamicMenuCategory>(_onDeleteDynamicMenuCategory);
    on<UpdateDynamicMenuCategoryVisibility>(
        _onUpdateDynamicMenuCategoryVisibility);
  }

  Future<void> _onLoadDynamicMenuCategories(
    LoadDynamicMenuCategories event,
    Emitter<DynamicMenuCategoriesState> emit,
  ) async {
    emit(DynamicMenuCategoriesLoading());
    try {
      final categories = await _apiClient.getMenuCategories();
      emit(DynamicMenuCategoriesLoaded(categories));
    } catch (e) {
      emit(DynamicMenuCategoriesError(e.toString()));
    }
  }

  Future<void> _onDeleteDynamicMenuCategory(
    DeleteDynamicMenuCategory event,
    Emitter<DynamicMenuCategoriesState> emit,
  ) async {
    try {
      await _apiClient.deleteMenuCategory(event.id);
      add(LoadDynamicMenuCategories());
    } catch (e) {
      emit(DynamicMenuCategoriesError(e.toString()));
    }
  }

  Future<void> _onUpdateDynamicMenuCategoryVisibility(
    UpdateDynamicMenuCategoryVisibility event,
    Emitter<DynamicMenuCategoriesState> emit,
  ) async {
    try {
      final category = event.category;
      await _apiClient.updateMenuCategory(
          category.Id,
          category.copyWith(
            isVisible: event.isVisible,
          ));
      add(LoadDynamicMenuCategories());
      context.read<MenuBloc>().add(LoadMenu());
    } catch (e) {
      emit(DynamicMenuCategoriesError(e.toString()));
    }
  }
}
