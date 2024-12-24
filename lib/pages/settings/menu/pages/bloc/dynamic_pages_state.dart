import 'package:querier/models/page.dart';

abstract class DynamicPagesState {}

class DynamicPagesInitial extends DynamicPagesState {}

class DynamicPagesLoading extends DynamicPagesState {}

class DynamicPagesLoaded extends DynamicPagesState {
  final List<MenuPage> pages;
  DynamicPagesLoaded(this.pages);
}

class DynamicPagesError extends DynamicPagesState {
  final String message;
  DynamicPagesError(this.message);
}
