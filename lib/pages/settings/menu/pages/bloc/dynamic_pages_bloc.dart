import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/page.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_event.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_state.dart';

class DynamicPagesBloc extends Bloc<DynamicPagesEvent, DynamicPagesState> {
  final ApiClient apiClient;

  DynamicPagesBloc(this.apiClient) : super(DynamicPagesInitial()) {
    on<LoadPages>(_onLoadPages);
    on<DeletePage>(_onDeletePage);
    on<UpdatePageVisibility>(_onUpdatePageVisibility);
    on<CreatePage>(_onCreatePage);
    on<UpdatePage>(_onUpdatePage);
  }

  Future<void> _onLoadPages(
      LoadPages event, Emitter<DynamicPagesState> emit) async {
    emit(DynamicPagesLoading());
    try {
      final pages = await apiClient.getPages(event.categoryId);
      emit(DynamicPagesLoaded(pages));
    } catch (e) {
      emit(DynamicPagesError(e.toString()));
    }
  }

  Future<void> _onDeletePage(
      DeletePage event, Emitter<DynamicPagesState> emit) async {
    try {
      await apiClient.deletePage(event.pageId);
      add(LoadPages((state as DynamicPagesLoaded).pages.first.menuCategoryId));
    } catch (e) {
      emit(DynamicPagesError(e.toString()));
    }
  }

  Future<void> _onUpdatePageVisibility(
      UpdatePageVisibility event, Emitter<DynamicPagesState> emit) async {
    try {
      event.page.isVisible = event.isVisible;
      await apiClient.updatePage(event.page.id, event.page);
      add(LoadPages(event.page.menuCategoryId));
    } catch (e) {
      emit(DynamicPagesError(e.toString()));
    }
  }

  Future<void> _onCreatePage(
      CreatePage event, Emitter<DynamicPagesState> emit) async {
    try {
      await apiClient.createPage(event.page);
      add(LoadPages(event.page.menuCategoryId));
    } catch (e) {
      emit(DynamicPagesError(e.toString()));
    }
  }

  Future<void> _onUpdatePage(
      UpdatePage event, Emitter<DynamicPagesState> emit) async {
    try {
      await apiClient.updatePage(event.page.id, event.page);
      add(LoadPages(event.page.menuCategoryId));
    } catch (e) {
      emit(DynamicPagesError(e.toString()));
    }
  }
}
