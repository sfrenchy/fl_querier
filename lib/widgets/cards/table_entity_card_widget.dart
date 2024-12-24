import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:querier/models/cards/table_card.dart';
import 'package:querier/widgets/cards/base_card_widget.dart';
import 'package:querier/api/api_client.dart';
import 'package:provider/provider.dart';
import 'package:querier/utils/data_formatter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TableEntityCardWidget extends BaseCardWidget {
  static const int _pageSize = 10;
  final _paginationController = StreamController<(int, int)>.broadcast();
  final _dataController =
      StreamController<(List<Map<String, dynamic>>, int)>.broadcast();

  // Cache pour stocker les données par page
  final Map<int, List<Map<String, dynamic>>> _dataCache = {};
  int? _totalItems;

  // Ajouter cette propriété à la classe TableEntityCardWidget
  String? _sortColumn;

  TableEntityCardWidget({
    super.key,
    required TableEntityCard card,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    Widget? dragHandle,
    bool isEditing = false,
    super.maxRowHeight,
  }) : super(
          card: card,
          onEdit: onEdit,
          onDelete: onDelete,
          dragHandle: dragHandle,
          isEditing: isEditing,
        );

  String _getPropertyType(String columnKey) {
    try {
      final tableCard = card as TableEntityCard;
      final entitySchema =
          tableCard.configuration['entitySchema'] as Map<String, dynamic>;
      final properties = entitySchema['Properties'] as List<dynamic>;
      final property = properties.firstWhere(
        (p) => p['Name'] == columnKey,
        orElse: () => {'Type': 'String'},
      );
      final type = property['Type'] as String? ?? 'String';
      return type;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du type: $e');
    }
    return 'String';
  }

  Future<void> _loadData(BuildContext buildContext, TableEntityCard card,
      {int page = 1}) async {
    // Vérifier si les données sont dans le cache
    if (_dataCache.containsKey(page)) {
      _dataController.add((_dataCache[page]!, _totalItems!));
      _paginationController.add((page, _totalItems!));
      return;
    }

    final apiClient = buildContext.read<ApiClient>();
    final context = card.configuration['context'] as String?;
    final entity = card.configuration['entity'] as String?;

    if (context == null || entity == null) {
      // Retourner une liste vide si la configuration n'est pas définie
      _dataCache[page] = [];
      _totalItems = 0;
      _paginationController.add((page, 0));
      _dataController.add(([], 0));
      return;
    }

    final result = await apiClient.getEntityData(
      context,
      entity,
      pageNumber: page,
      pageSize: _pageSize,
      orderBy: _sortColumn == null ? "" : _sortColumn!,
    );

    // Mettre en cache les données
    _dataCache[page] = result.$1;
    _totalItems = result.$2;

    _paginationController.add((page, result.$2));
    _dataController.add(result);
  }

  void clearCache() {
    _dataCache.clear();
    _totalItems = null;
  }

  @override
  Widget? buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget buildCardContent(BuildContext context) {
    final tableCard = card as TableEntityCard;
    final hasConfig = tableCard.configuration['context'] != null &&
        tableCard.configuration['entity'] != null;

    // Ne charger les données que si on a une configuration
    if (hasConfig) {
      _loadData(context, tableCard, page: 1);
    }

    return SizedBox(
      width: double.infinity,
      child: StreamBuilder<(List<Map<String, dynamic>>, int)>(
        stream: _dataController.stream,
        builder: (context, snapshot) {
          // Si pas de configuration, afficher directement le message
          if (!hasConfig) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, size: 48),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.configurationRequired),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final (items, _) = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Aucune donnée'));
          }

          // Création des controllers dans le builder
          final horizontalController = ScrollController();
          final verticalController = ScrollController();

          return Scrollbar(
            controller: verticalController,
            thumbVisibility: true,
            trackVisibility: true,
            child: Scrollbar(
              controller: horizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              notificationPredicate: (notif) => notif.depth == 1,
              child: SingleChildScrollView(
                controller: verticalController,
                child: SingleChildScrollView(
                  controller: horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: tableCard.columns
                        .where((column) => column['visible'] == true)
                        .map((column) => DataColumn(
                              label: Align(
                                alignment: _getAlignment(
                                    column['alignment'] as String?),
                                child: Text(
                                  column['label']?[
                                          Localizations.localeOf(context)
                                              .languageCode] ??
                                      column['key'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              onSort: (_, __) {
                                _sortColumn = column['key'];
                                clearCache();
                                _loadData(context, tableCard, page: 1);
                              },
                            ))
                        .toList(),
                    rows: items
                        .map((row) => DataRow(
                              cells: tableCard.columns
                                  .where((column) => column['visible'] == true)
                                  .map((column) => DataCell(
                                        Align(
                                          alignment: _getAlignment(
                                              column['alignment'] as String?),
                                          child: Text(DataFormatter.format(
                                            row[column['key']],
                                            _getPropertyType(column['key']),
                                            context,
                                          )),
                                        ),
                                      ))
                                  .toList(),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget? buildFooter(BuildContext context) {
    return StreamBuilder<(int, int)>(
      stream: _paginationController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final (currentPage, totalItems) = snapshot.data!;
        final startIndex = (currentPage - 1) * _pageSize + 1;
        final endIndex = min(startIndex + _pageSize - 1, totalItems);
        final totalPages = (totalItems / _pageSize).ceil();

        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('$startIndex-$endIndex sur $totalItems'),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => _loadData(context, card as TableEntityCard,
                        page: currentPage - 1)
                    : null,
              ),
              DropdownButton<int>(
                value: currentPage,
                isDense: true,
                items: List.generate(totalPages, (index) => index + 1)
                    .map((page) => DropdownMenuItem(
                          value: page,
                          child: Text('$page / $totalPages'),
                        ))
                    .toList(),
                onChanged: (newPage) {
                  if (newPage != null) {
                    _loadData(context, card as TableEntityCard, page: newPage);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => _loadData(context, card as TableEntityCard,
                        page: currentPage + 1)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _paginationController.close();
    _dataController.close();
    _dataCache.clear();
  }

  Alignment _getAlignment(String? alignment) {
    switch (alignment?.toLowerCase()) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      case 'center':
        return Alignment.center;
      default:
        return Alignment.centerLeft; // Alignement par défaut
    }
  }
}
