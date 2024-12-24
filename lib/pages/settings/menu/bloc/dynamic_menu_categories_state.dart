part of 'dynamic_menu_categories_bloc.dart';

abstract class DynamicMenuCategoriesState extends Equatable {
  const DynamicMenuCategoriesState();

  @override
  List<Object> get props => [];
}

class DynamicMenuCategoriesInitial extends DynamicMenuCategoriesState {}

class DynamicMenuCategoriesLoading extends DynamicMenuCategoriesState {}

class DynamicMenuCategoriesLoaded extends DynamicMenuCategoriesState {
  final List<MenuCategory> categories;

  const DynamicMenuCategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class DynamicMenuCategoriesError extends DynamicMenuCategoriesState {
  final String message;

  const DynamicMenuCategoriesError(this.message);

  @override
  List<Object> get props => [message];
}
