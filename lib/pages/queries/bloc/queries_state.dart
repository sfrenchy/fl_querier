import 'package:equatable/equatable.dart';
import 'package:querier/models/sql_query.dart';

abstract class QueriesState extends Equatable {
  const QueriesState();

  @override
  List<Object> get props => [];
}

class QueriesInitial extends QueriesState {}

class QueriesLoading extends QueriesState {}

class QueriesLoaded extends QueriesState {
  final List<SQLQuery> queries;

  const QueriesLoaded(this.queries);

  @override
  List<Object> get props => [queries];
}

class QueriesError extends QueriesState {
  final String message;

  const QueriesError(this.message);

  @override
  List<Object> get props => [message];
}
