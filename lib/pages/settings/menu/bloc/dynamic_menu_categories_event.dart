part of 'dynamic_menu_categories_bloc.dart';

abstract class DynamicMenuCategoriesEvent extends Equatable {
  const DynamicMenuCategoriesEvent();

  @override
  List<Object> get props => [];
}

class LoadDynamicMenuCategories extends DynamicMenuCategoriesEvent {}

class DeleteDynamicMenuCategory extends DynamicMenuCategoriesEvent {
  final int id;

  const DeleteDynamicMenuCategory(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateDynamicMenuCategoryVisibility extends DynamicMenuCategoriesEvent {
  final MenuCategory category;
  final bool isVisible;

  const UpdateDynamicMenuCategoryVisibility(this.category, this.isVisible);

  @override
  List<Object> get props => [category, isVisible];
}
