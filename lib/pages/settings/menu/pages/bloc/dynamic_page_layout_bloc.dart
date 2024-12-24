import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/cards/placeholder_card.dart';
import 'package:querier/models/cards/table_card.dart';
import 'package:querier/models/dynamic_card.dart';
import 'package:querier/models/dynamic_row.dart';
import 'package:querier/models/layout.dart';
import 'dynamic_page_layout_event.dart';
import 'dynamic_page_layout_state.dart';

class DynamicPageLayoutBloc
    extends Bloc<DynamicPageLayoutEvent, DynamicPageLayoutState> {
  final ApiClient _apiClient;

  DynamicPageLayoutBloc(this._apiClient) : super(DynamicPageLayoutInitial()) {
    on<LoadPageLayout>(_onLoadPageLayout);
    on<AddRow>(_onAddRow);
    on<AddCardToRow>(_onAddCard);
    on<UpdateCard>(_onUpdateCard);
    on<SaveLayout>(_onSaveLayout);
    on<DeleteRow>(_onDeleteRow);
    on<DeleteCard>((event, emit) async {
      if (state is DynamicPageLayoutLoaded) {
        try {
          final currentState = state as DynamicPageLayoutLoaded;

          // Créer une nouvelle liste de rows
          final updatedRows = currentState.rows.map((row) {
            if (row.id == event.rowId) {
              // Créer une nouvelle liste de cartes sans la carte supprimée
              final updatedCards =
                  row.cards.where((card) => card.id != event.cardId).toList();
              return row.copyWith(cards: updatedCards);
            }
            return row;
          }).toList();

          // Émettre le nouvel état
          emit(DynamicPageLayoutLoaded(
            updatedRows,
            isDirty: true,
          ));
        } catch (e) {
          emit(DynamicPageLayoutError('Error deleting card: $e'));
        }
      }
    });
    on<UpdateRowProperties>((event, emit) {
      print('UpdateRowProperties height: ${event.height}');
      if (state is DynamicPageLayoutLoaded) {
        final currentState = state as DynamicPageLayoutLoaded;
        final updatedRows = currentState.rows.map((row) {
          if (row.id == event.rowId) {
            final updatedRow = row.copyWith(
              height: event.height,
            );
            print('Updated row height: ${updatedRow.height}');
            return updatedRow;
          }
          return row;
        }).toList();

        emit(DynamicPageLayoutLoaded(
          updatedRows,
          isDirty: true,
        ));
      }
    });
    on<ReloadPageLayout>((event, emit) async {
      emit(DynamicPageLayoutLoading());
      try {
        final layout = await _apiClient.getLayout(event.pageId);
        emit(DynamicPageLayoutLoaded(layout.rows));
      } catch (e) {
        emit(DynamicPageLayoutError(e.toString()));
      }
    });
  }

  Future<void> _onUpdateCard(
      UpdateCard event, Emitter<DynamicPageLayoutState> emit) async {
    if (state is DynamicPageLayoutLoaded) {
      final currentState = state as DynamicPageLayoutLoaded;
      final updatedRows = currentState.rows.map((row) {
        if (row.id == event.rowId) {
          final updatedCards = row.cards.map((card) {
            if (card.id == event.card.id) {
              return event.card;
            }
            return card;
          }).toList();
          return row.copyWith(cards: updatedCards);
        }
        return row;
      }).toList();

      emit(DynamicPageLayoutLoaded(updatedRows, isDirty: true));
    }
  }

  Future<void> _onSaveLayout(
      SaveLayout event, Emitter<DynamicPageLayoutState> emit) async {
    if (state is DynamicPageLayoutLoaded) {
      try {
        final currentState = state as DynamicPageLayoutLoaded;
        emit(DynamicPageLayoutSaving());

        final layout = Layout(
          pageId: event.pageId,
          rows: currentState.rows,
          icon: 'dashboard',
          names: const {'en': 'Page Layout', 'fr': 'Mise en page'},
          isVisible: true,
          roles: const ['User'],
          route: '/layout',
        );

        await _apiClient.updateLayout(event.pageId, layout);
        emit(DynamicPageLayoutLoaded(currentState.rows, isDirty: false));
      } catch (e) {
        emit(DynamicPageLayoutError(e.toString()));
      }
    }
  }

  Future<void> _onLoadPageLayout(
      LoadPageLayout event, Emitter<DynamicPageLayoutState> emit) async {
    emit(DynamicPageLayoutLoading());
    try {
      final layout = await _apiClient.getLayout(event.pageId);
      emit(DynamicPageLayoutLoaded(layout.rows));
    } catch (e) {
      emit(DynamicPageLayoutError(e.toString()));
    }
  }

  Future<void> _onAddRow(
      AddRow event, Emitter<DynamicPageLayoutState> emit) async {
    if (state is DynamicPageLayoutLoaded) {
      final currentState = state as DynamicPageLayoutLoaded;
      final newRow = DynamicRow(
        id: -(currentState.rows.length + 1),
        pageId: event.pageId,
        order: currentState.rows.length + 1,
        alignment: MainAxisAlignment.start,
        crossAlignment: CrossAxisAlignment.start,
        spacing: 16.0,
        height: event.height,
        cards: const [],
      );

      final updatedRows = [...currentState.rows, newRow];
      emit(DynamicPageLayoutLoaded(updatedRows, isDirty: true));
    }
  }

  Future<void> _onAddCard(
      AddCardToRow event, Emitter<DynamicPageLayoutState> emit) async {
    print('_onAddCard: initial gridWidth = ${event.card.gridWidth}');
    if (state is DynamicPageLayoutLoaded) {
      final currentState = state as DynamicPageLayoutLoaded;
      final row = currentState.rows.firstWhere((r) => r.id == event.rowId);

      // Créer une nouvelle carte en préservant le gridWidth
      final newCard = DynamicCard(
        id: -(row.cards.length + 1),
        titles: event.card.titles,
        order: row.cards.length + 1,
        type: event.card.type,
        gridWidth: event.card.gridWidth, // Préserver le gridWidth
        backgroundColor: event.card.backgroundColor,
        textColor: event.card.textColor,
        headerBackgroundColor: event.card.headerBackgroundColor,
        headerTextColor: event.card.headerTextColor,
        configuration: event.card.configuration,
      );

      print('_onAddCard: final gridWidth = ${newCard.gridWidth}');

      final updatedRows = currentState.rows.map((r) {
        if (r.id == event.rowId) {
          return r.copyWith(cards: [...r.cards, newCard]);
        }
        return r;
      }).toList();

      emit(DynamicPageLayoutLoaded(updatedRows, isDirty: true));
    }
  }

  Future<void> _onDeleteRow(
      DeleteRow event, Emitter<DynamicPageLayoutState> emit) async {
    if (state is DynamicPageLayoutLoaded) {
      final currentState = state as DynamicPageLayoutLoaded;
      final updatedRows =
          currentState.rows.where((row) => row.id != event.rowId).toList();

      emit(DynamicPageLayoutLoaded(updatedRows, isDirty: true));
    }
  }
}
