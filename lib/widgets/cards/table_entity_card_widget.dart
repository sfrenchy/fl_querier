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
      final column = tableCard.columns.firstWhere(
        (col) => col['key'] == columnKey,
        orElse: () => {'type': 'String'},
      );
      return column['type'] as String? ?? 'String';
    } catch (e) {
      debugPrint('Erreur lors de la récupération du type: $e');
      return 'String';
    }
  }

  Future<void> _loadData(BuildContext context, TableEntityCard card,
      {int page = 1}) async {
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
    _dataCache[page] = (result.$1 as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
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
          final items = (rawItems as List)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
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
                                          child: _buildCellContent(context,
                                              row[column['key']], column),
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

  bool _isJpegHeader(Uint8List bytes) {
    if (bytes.length < 3) return false;
    return bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
  }

  bool _isPngHeader(Uint8List bytes) {
    if (bytes.length < 8) return false;
    return bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }

  Uint8List _addJpegHeader(Uint8List bytes) {
    var header = Uint8List.fromList([
      0xFF,
      0xD8,
      0xFF,
      0xE0,
      0x00,
      0x10,
      0x4A,
      0x46,
      0x49,
      0x46,
      0x00,
      0x01,
      0x01,
      0x00,
      0x00,
      0x01,
      0x00,
      0x01,
      0x00,
      0x00
    ]);
    var result = Uint8List(header.length + bytes.length);
    result.setAll(0, header);
    result.setAll(header.length, bytes);
    return result;
  }

  bool _isBmpHeader(Uint8List bytes) {
    if (bytes.length < 2) return false;
    return bytes[0] == 0x42 && bytes[1] == 0x4D; // 'BM' en ASCII
  }

  Uint8List? _extractImageFromOLE(Uint8List oleData) {
    try {
      // Recherche des signatures d'en-tête d'image courantes dans les données OLE
      // JPEG: FF D8 FF
      // PNG: 89 50 4E 47
      // BMP: 42 4D (BM en ASCII)
      for (var i = 0; i < oleData.length - 3; i++) {
        // Vérifier l'en-tête BMP
        if (i < oleData.length - 2 &&
            oleData[i] == 0x42 &&
            oleData[i + 1] == 0x4D) {
          debugPrint('En-tête BMP trouvé à la position $i');
          return Uint8List.fromList(oleData.sublist(i));
        }
        // Vérifier l'en-tête JPEG
        if (oleData[i] == 0xFF &&
            oleData[i + 1] == 0xD8 &&
            oleData[i + 2] == 0xFF) {
          debugPrint('En-tête JPEG trouvé à la position $i');
          return Uint8List.fromList(oleData.sublist(i));
        }
        // Vérifier l'en-tête PNG
        if (i < oleData.length - 8 &&
            oleData[i] == 0x89 &&
            oleData[i + 1] == 0x50 &&
            oleData[i + 2] == 0x4E &&
            oleData[i + 3] == 0x47 &&
            oleData[i + 4] == 0x0D &&
            oleData[i + 5] == 0x0A &&
            oleData[i + 6] == 0x1A &&
            oleData[i + 7] == 0x0A) {
          debugPrint('En-tête PNG trouvé à la position $i');
          return Uint8List.fromList(oleData.sublist(i));
        }
      }

      // Si aucun en-tête n'est trouvé, afficher les premiers octets pour le débogage
      if (oleData.length > 0) {
        debugPrint(
            'Premiers octets des données: [${oleData.take(20).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}]');
      }

      debugPrint('Aucun en-tête d\'image trouvé dans les données OLE');
      return null;
    } catch (e) {
      debugPrint(
          'Erreur lors de l\'extraction de l\'image des données OLE: $e');
      return null;
    }
  }

  Widget _buildCellContent(
      BuildContext context, dynamic value, Map<String, dynamic> column) {
    if (value == null) return const Text('');

    final type = _getPropertyType(column['key']);
    if (['Byte[]', 'byte[]'].contains(type)) {
      final byteArrayType = column['byteArrayType'] ?? 'Raw';
      if (byteArrayType == 'Image') {
        Uint8List? bytes;
        try {
          if (value is String) {
            // Supprimer les caractères non-base64 potentiels
            final cleanBase64 =
                value.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
            bytes = base64Decode(cleanBase64);
          } else if (value is List) {
            bytes = Uint8List.fromList(value.cast<int>());
          } else {
            debugPrint(
                'Type de données non supporté pour l\'image: ${value.runtimeType}');
            return const Text('Invalid image data type');
          }

          if (bytes == null || bytes.isEmpty) {
            debugPrint('Données d\'image vides');
            return const Text('Empty image data');
          }

          // Essayer d'extraire l'image des données OLE
          final imageBytes = _extractImageFromOLE(bytes);
          if (imageBytes == null) {
            debugPrint('Impossible d\'extraire l\'image des données OLE');
            return const Text('Invalid OLE image data');
          }

          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: InkWell(
              onTap: () => _showFullImage(context, imageBytes),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Erreur de chargement de l\'image: $error');
                  debugPrint(
                      'Premiers octets: [${imageBytes.take(10).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}]');
                  return const Center(child: Icon(Icons.broken_image));
                },
              ),
            ),
          );
        } catch (e) {
          debugPrint('Erreur lors de la conversion des données en image: $e');
          return const Text('Error loading image');
        }
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
