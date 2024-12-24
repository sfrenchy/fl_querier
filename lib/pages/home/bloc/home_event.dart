part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboard extends HomeEvent {
  final int pageId;

  const LoadDashboard(this.pageId);

  @override
  List<Object> get props => [pageId];
}

class RefreshDashboard extends HomeEvent {
  final int pageId;

  const RefreshDashboard(this.pageId);

  @override
  List<Object> get props => [pageId];
}

class LogoutRequested extends HomeEvent {}
