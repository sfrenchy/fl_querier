import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:querier/models/cards/table_card.dart';
import 'package:querier/widgets/cards/base_card_widget.dart';
import 'package:querier/api/api_client.dart';
import 'package:provider/provider.dart';
import 'package:querier/utils/data_formatter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/widgets/data_source_selector.dart';

class TableEntityCardWidget extends BaseCardWidget {
  static const int _pageSize = 10;
  final _paginationController = StreamController<(int, int)>.broadcast();
  final _dataController = StreamController<(List<dynamic>, int)>.broadcast();

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
      final entitySchema = tableCard.configuration['entitySchema'];
      if (entitySchema == null) return 'String';

      final properties = (entitySchema as Map<String, dynamic>)['Properties'] as List<dynamic>;
      final property = properties.firstWhere(
        (p) => p['Name'] == columnKey,
        orElse: () => {'Type': 'String'},
      );
      final type = property['Type'] as String? ?? 'String';
      return type;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du type: $e');
      return 'String';
    }
  }

  Future<void> _loadData(BuildContext context, TableEntityCard card, {int page = 1}) async {
    // Vérifier si les données sont dans le cache
    if (_dataCache.containsKey(page)) {
      _dataController.add((_dataCache[page]!, _totalItems!));
      _paginationController.add((page, _totalItems!));
      return;
    }

    final apiClient = context.read<ApiClient>();
    final config = DataSourceConfiguration.fromJson(card.configuration);

    final result = await config.fetchData(
      apiClient,
      pageNumber: page,
      pageSize: _pageSize,
      orderBy: _sortColumn ?? "",
    );

    // Mettre en cache les données
    _dataCache[page] = (result.$1 as List).map((item) => Map<String, dynamic>.from(item)).toList();
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
    final config = DataSourceConfiguration.fromJson(tableCard.configuration);
    final columns = tableCard.configuration['columns'] as List?;
    
    // Ajouter des logs de débogage
    debugPrint('Configuration: ${tableCard.configuration}');
    debugPrint('Columns in config: $columns');
    debugPrint('DataSource type: ${config.type}');
    debugPrint('DataSource query: ${config.query}');

    // Vérifier la configuration
    if (!_isConfigurationValid(config, columns)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 48),
            SizedBox(height: 8),
            Text('Configuration required'),
          ],
        ),
      );
    }

    // Initialiser les colonnes si nécessaire
    if (tableCard.columns.isEmpty && columns != null) {
      tableCard.columns = List<Map<String, dynamic>>.from(columns);
    }

    // Charger les données
    _loadData(context, tableCard, page: 1);

    return SizedBox(
      width: double.infinity,
      child: StreamBuilder<(List<dynamic>, int)>(
        stream: _dataController.stream,
        builder: (context, snapshot) {
          // Vérifier si les colonnes sont vides
          if (tableCard.columns.isEmpty) {
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

          final (rawItems, _) = snapshot.data!;
          final items = (rawItems as List).map((item) => Map<String, dynamic>.from(item)).toList();
          if (items.isEmpty) {
            return const Center(child: Text('Aucune donnée'));
          }

          // Vérifier qu'il y a au moins une colonne visible
          final visibleColumns = tableCard.columns
              .where((column) => column['visible'] == true)
              .toList();
          
          if (visibleColumns.isEmpty) {
            return const Center(child: Text('No visible columns'));
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
                                          child: _buildCellContent(context, row[column['key']], column),
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

  String _getDefaultAlignment(String type) {
    switch (type) {
      case 'String':
        return 'left';
      case 'Int32':
      case 'Decimal':
      case 'Double':
        return 'right';
      default:
        return 'left';
    }
  }

  bool _isConfigurationValid(DataSourceConfiguration config, List? columns) {
    debugPrint('Validating configuration:');
    debugPrint('- Type: ${config.type}');
    debugPrint('- Query: ${config.query}');
    debugPrint('- Columns: ${columns?.length ?? 0}');

    // Vérifier si c'est une configuration de requête
    if (config.query != null) {
      return columns != null && columns.isNotEmpty;
    }
    
    // Sinon, vérifier si c'est une configuration d'entité
    return config.context != null && 
           config.entity != null && 
           columns != null && 
           columns.isNotEmpty;
  }

  Widget _buildCellContent(BuildContext context, dynamic value, Map<String, dynamic> column) {
    if (value == null) return const Text('');
    
    final type = _getPropertyType(column['key']);
    if (['Byte[]', 'byte[]'].contains(type)) {
      final byteArrayType = column['byteArrayType'] ?? 'Raw';
      if (byteArrayType == 'Image') {
        Uint8List bytes;
        if (value is String) {
          // Si les données sont en base64
          bytes = base64Decode(value);
        } else if (value is List) {
          // Si les données sont déjà en bytes
          bytes = Uint8List.fromList(value.cast<int>());
        } else {
          return const Text('Invalid image data');
        }
        
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: InkWell(
            onTap: () => _showFullImage(context, bytes),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image));
              },
            ),
          ),
        );
      }
    }
    
    return Text(DataFormatter.format(
      value,
      type,
      context,
    ));
  }

  void _showFullImage(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 600,
          ),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
