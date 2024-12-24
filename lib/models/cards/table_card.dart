import 'package:querier/models/dynamic_card.dart';

class TableEntityCard extends DynamicCard {
  static const List<Map<String, dynamic>> defaultColumns = [
    {
      'key': 'id',
      'label': {'en': 'ID', 'fr': 'ID'}
    },
  ];

  static const List<Map<String, dynamic>> defaultData = [];

  List<Map<String, dynamic>> get columns =>
      ((configuration['columns'] as List?)
          ?.map((col) => Map<String, dynamic>.from(col))
          .toList()) ??
      defaultColumns;

  List<Map<String, dynamic>> get data =>
      ((configuration['data'] as List?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList()) ??
      defaultData;

  const TableEntityCard({
    required super.id,
    required super.titles,
    required super.order,
    super.gridWidth,
    super.backgroundColor,
    super.textColor,
    super.headerTextColor,
    super.headerBackgroundColor,
    Map<String, dynamic>? configuration,
  }) : super(
          type: 'TableEntity',
          configuration: configuration ??
              const {
                'columns': defaultColumns,
                'data': defaultData,
              },
        );
}
