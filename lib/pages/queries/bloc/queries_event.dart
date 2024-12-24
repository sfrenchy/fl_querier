import 'package:equatable/equatable.dart';
import 'package:querier/models/sql_query.dart';

abstract class QueriesEvent extends Equatable {
  const QueriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadQueries extends QueriesEvent {}

class DeleteQuery extends QueriesEvent {
  final int queryId;

  const DeleteQuery(this.queryId);

  @override
  List<Object> get props => [queryId];
}

class AddQuery extends QueriesEvent {
  final SQLQuery query;
  final Map<String, dynamic>? sampleParameters;

  const AddQuery(this.query, {this.sampleParameters});

  @override
  List<Object?> get props => [query, sampleParameters];
}

class UpdateQuery extends QueriesEvent {
  final SQLQuery query;
  final Map<String, dynamic>? sampleParameters;

  const UpdateQuery(this.query, {this.sampleParameters});

  @override
  List<Object?> get props => [query, sampleParameters];
}
