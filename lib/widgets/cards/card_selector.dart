import 'package:flutter/material.dart';
import 'package:querier/models/dynamic_card.dart';
import 'package:querier/models/cards/placeholder_card.dart';
import 'package:querier/widgets/cards/fl_line_chart_card_widget.dart';
import 'package:querier/widgets/cards/placeholder_card_config.dart';
import 'package:querier/widgets/cards/placeholder_card_widget.dart';
import 'package:querier/models/cards/table_card.dart';
import 'package:querier/widgets/cards/table_entity_card_widget.dart';
import 'package:querier/widgets/cards/table_entity_card_config.dart';
import 'package:querier/widgets/cards/fl_line_chart_card_config.dart';

class CardSelector extends StatelessWidget {
  final DynamicCard card;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? dragHandle;
  final ValueChanged<Map<String, dynamic>>? onConfigurationChanged;
  final bool isEditing;
  final double? rowMaxHeight;

  const CardSelector({
    Key? key,
    required this.card,
    this.onEdit,
    this.onDelete,
    this.dragHandle,
    this.onConfigurationChanged,
    this.isEditing = false,
    this.rowMaxHeight,
  }) : super(key: key);

  Widget? buildConfigurationWidget() {
    switch (card.type) {
      case 'Placeholder':
        if (onConfigurationChanged != null) {
          final placeholderCard = PlaceholderCard(
            id: card.id,
            titles: card.titles,
            order: card.order,
            gridWidth: card.gridWidth,
            backgroundColor: card.backgroundColor,
            textColor: card.textColor,
            configuration: card.configuration,
          );
          return PlaceholderCardConfig(
            card: placeholderCard,
            onConfigurationChanged: onConfigurationChanged!,
          );
        }
        return null;
      case 'TableEntity':
        if (onConfigurationChanged != null) {
          final tableCard = TableEntityCard(
            id: card.id,
            titles: card.titles,
            order: card.order,
            gridWidth: card.gridWidth,
            backgroundColor: card.backgroundColor,
            textColor: card.textColor,
            headerBackgroundColor: card.headerBackgroundColor,
            headerTextColor: card.headerTextColor,
            configuration: card.configuration,
          );
          return TableEntityCardConfig(
            card: tableCard,
            onConfigurationChanged: onConfigurationChanged!,
          );
        }
        return null;
      case 'FLLineChart':
        if (onConfigurationChanged != null) {
          final lineChartCard = DynamicCard(
            id: card.id,
            titles: card.titles,
            type: card.type,
            order: card.order,
            gridWidth: card.gridWidth,
            backgroundColor: card.backgroundColor,
            textColor: card.textColor,
            configuration: card.configuration,
          );
          return FLLineChartCardConfig(
            card: lineChartCard,
            onConfigurationChanged: onConfigurationChanged!,
          );
        }
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (card.type) {
      case 'Placeholder':
        final placeholderCard = PlaceholderCard(
          id: card.id,
          titles: card.titles,
          order: card.order,
          gridWidth: card.gridWidth,
          backgroundColor: card.backgroundColor,
          textColor: card.textColor,
          configuration: card.configuration,
        );
        return PlaceholderCardWidget(
          card: placeholderCard,
          onEdit: onEdit,
          onDelete: onDelete,
          dragHandle: dragHandle,
          isEditing: isEditing,
          maxRowHeight: rowMaxHeight,
        );
      case 'TableEntity':
        final tableCard = TableEntityCard(
          id: card.id,
          titles: card.titles,
          order: card.order,
          gridWidth: card.gridWidth,
          backgroundColor: card.backgroundColor,
          textColor: card.textColor,
          headerBackgroundColor: card.headerBackgroundColor,
          headerTextColor: card.headerTextColor,
          configuration: card.configuration,
        );
        return TableEntityCardWidget(
          card: tableCard,
          onEdit: onEdit,
          onDelete: onDelete,
          dragHandle: dragHandle,
          isEditing: isEditing,
          maxRowHeight: rowMaxHeight,
        );
      case 'FLLineChart':
        final lineChartCard = DynamicCard(
          id: card.id,
          titles: card.titles,
          type: card.type,
          order: card.order,
          gridWidth: card.gridWidth,
          backgroundColor: card.backgroundColor,
          textColor: card.textColor,
          configuration: card.configuration,
        );
        return FLLineChartCardWidget(
          card: lineChartCard,
          onEdit: onEdit,
          onDelete: onDelete,
          dragHandle: dragHandle,
          isEditing: isEditing,
          maxRowHeight: rowMaxHeight,
        );
      default:
        return Card(
          child: Center(
            child: Text('Unknown card type: ${card.type}'),
          ),
        );
    }
  }
}
