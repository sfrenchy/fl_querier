import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:querier/models/dynamic_card.dart';
import 'package:querier/models/dynamic_row.dart';

abstract class DynamicPageLayoutEvent extends Equatable {
  const DynamicPageLayoutEvent();

  @override
  List<Object> get props => [];
}

class LoadPageLayout extends DynamicPageLayoutEvent {
  final int pageId;

  const LoadPageLayout(this.pageId);

  @override
  List<Object> get props => [pageId];
}

class AddRow extends DynamicPageLayoutEvent {
  final int pageId;
  final double height;

  const AddRow(this.pageId, {this.height = 500.0});

  @override
  List<Object> get props => [pageId, height];
}

class ReorderCardsInRow extends DynamicPageLayoutEvent {
  final int rowId;
  final int oldIndex;
  final int newIndex;

  const ReorderCardsInRow(this.rowId, this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [rowId, oldIndex, newIndex];
}

class UpdateRowProperties extends DynamicPageLayoutEvent {
  final int rowId;
  final MainAxisAlignment alignment;
  final CrossAxisAlignment crossAlignment;
  final double spacing;
  final double height;

  const UpdateRowProperties(
      this.rowId, this.alignment, this.crossAlignment, this.spacing,
      {this.height = 400});

  @override
  List<Object> get props => [rowId, alignment, crossAlignment, spacing, height];
}

class DeleteRow extends DynamicPageLayoutEvent {
  final int rowId;

  const DeleteRow(this.rowId);

  @override
  List<Object> get props => [rowId];
}

class SaveLayout extends DynamicPageLayoutEvent {
  final int pageId;

  const SaveLayout(this.pageId);

  @override
  List<Object> get props => [pageId];
}

class AddCard extends DynamicPageLayoutEvent {
  final int rowId;
  final String cardType;

  const AddCard(this.rowId, this.cardType);

  @override
  List<Object> get props => [rowId, cardType];
}

class AddCardToRow extends DynamicPageLayoutEvent {
  final int rowId;
  final DynamicCard card;

  const AddCardToRow(this.rowId, this.card);

  @override
  List<Object> get props => [rowId, card];
}

class DeleteCard extends DynamicPageLayoutEvent {
  final int rowId;
  final int cardId;

  const DeleteCard(this.rowId, this.cardId);

  @override
  List<Object> get props => [rowId, cardId];
}

class ReloadPageLayout extends DynamicPageLayoutEvent {
  final int pageId;

  const ReloadPageLayout(this.pageId);

  @override
  List<Object> get props => [pageId];
}

class ReorderRows extends DynamicPageLayoutEvent {
  final int pageId;
  final List<int> rowIds;

  const ReorderRows(this.pageId, this.rowIds);

  @override
  List<Object> get props => [pageId, rowIds];
}

class UpdateCard extends DynamicPageLayoutEvent {
  final int rowId;
  final DynamicCard card;

  const UpdateCard(this.rowId, this.card);

  @override
  List<Object> get props => [rowId, card];
}
