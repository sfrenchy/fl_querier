import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/cards/table_card.dart';
import 'package:provider/provider.dart';
import 'package:querier/models/entity_schema.dart';
import 'package:querier/widgets/translation_manager.dart';
import 'package:querier/services/data_context_service.dart';
import 'package:querier/widgets/data_source_selector.dart';
import 'dart:convert';

class TableEntityCardConfig extends StatefulWidget {
  final TableEntityCard card;
  final ValueChanged<Map<String, dynamic>> onConfigurationChanged;

  const TableEntityCardConfig({
    Key? key,
    required this.card,
    required this.onConfigurationChanged,
  }) : super(key: key);

  @override
  State<TableEntityCardConfig> createState() => _TableEntityCardConfigState();
}

class _TableEntityCardConfigState extends State<TableEntityCardConfig> {
  List<Map<String, dynamic>> _selectedColumns = [];
  final Map<String, bool> _expandedStates = {};
  late DataSourceConfiguration _dataSourceConfig;
  List<PropertyDefinition> _availableColumns = [];

  @override
  void initState() {
    super.initState();
    _dataSourceConfig = DataSourceConfiguration.fromJson(widget.card.configuration);
    
    // Charger les colonnes si elles existent déjà dans la configuration
    final existingColumns = widget.card.configuration['columns'] as List?;
    if (existingColumns != null) {
      setState(() {
        _selectedColumns = List<Map<String, dynamic>>.from(existingColumns.map((col) {
          // S'assurer que le label est une Map<String, String> valide
          Map<String, String> label;
          if (col['label'] is Map) {
            label = Map<String, String>.from(col['label'] as Map);
          } else {
            label = {
              'en': col['key'].toString(),
              'fr': col['key'].toString()
            };
          }

          return {
            'key': col['key'],
            'type': col['type'],
            'label': label,
            'alignment': col['alignment'],
            'visible': col['visible'] ?? true,
            'decimals': col['decimals'],
            'byteArrayType': col['byteArrayType'],
          };
        }));
      });
    }

    // Charger les propriétés disponibles
    _loadAvailableProperties();
  }

  void _initializeColumns() {
    if (_dataSourceConfig.entitySchema != null) {
      final existingColumns = widget.card.configuration['columns'] as List?;
      setState(() {
        _selectedColumns = _dataSourceConfig.entitySchema!.properties.map((prop) {
          Map<String, dynamic>? existingColumn;
          if (existingColumns != null) {
            try {
              existingColumn = existingColumns.firstWhere(
                (c) => c['key'] == prop.name,
              ) as Map<String, dynamic>;
            } catch (_) {
              existingColumn = null;
            }
          }

          // S'assurer que label est toujours une Map valide
          Map<String, dynamic> label = existingColumn?['label'] ?? {
            'en': prop.name,
            'fr': prop.name,
          };

          return {
            'key': prop.name,
            'type': prop.type,
            'label': label,
            'alignment': existingColumn?['alignment'] ?? _getDefaultAlignment(prop.type),
            'visible': existingColumn?['visible'] ?? true,
            'decimals': existingColumn?['decimals'] ?? (_isNumericType(prop.type) ? 0 : null),
            'byteArrayType': existingColumn?['byteArrayType'] ?? (_isByteArrayType(prop.type) ? 'Raw' : null),
          };
        }).toList();
      });
    }
  }

  bool _isNumericType(String type) {
    return [
      'Decimal',
      'Double',
      'Single',
      'Int32',
      'Int16',
      'Decimal?',
      'Double?',
      'Single?',
      'Int32?',
      'Int16?'
    ].contains(type);
  }

  bool _isByteArrayType(String type) {
    return ['Byte[]', 'byte[]'].contains(type);
  }

  String _getDefaultAlignment(String type) {
    switch (type) {
      case 'String':
        return 'left';
      case 'Int32':
      case 'Int64':
      case 'Decimal':
      case 'Double':
        return 'right';
      default:
        return 'left';
    }
  }

  void _updateColumnConfiguration() {
    Map<String, dynamic> newConfig = Map<String, dynamic>.from(widget.card.configuration);
    
    newConfig['columns'] = _selectedColumns.map((col) {
      // S'assurer que le label est une Map<String, String>
      Map<String, String> label = Map<String, String>.from(col['label'] as Map);
      
      return {
        'key': col['key'],
        'label': label,
        'type': col['type'],
        'alignment': col['alignment'],
        'visible': col['visible'],
        'decimals': col['decimals'],
        'byteArrayType': col['byteArrayType'],
      };
    }).toList();

    widget.onConfigurationChanged(newConfig);
  }

  void _onDataSourceConfigurationChanged(DataSourceConfiguration config) {
    debugPrint('Configuration: ${config.toJson()}');
    debugPrint('EntitySchema: ${config.entitySchema}');
    
    setState(() {
      _dataSourceConfig = config;
      if (config.entitySchema != null) {
        final existingColumns = _selectedColumns; // Utiliser les colonnes déjà chargées
        
        _selectedColumns = config.entitySchema!.properties.map((p) {
          Map<String, dynamic>? existingColumn;
          if (_selectedColumns.isNotEmpty) {
            try {
              existingColumn = _selectedColumns.firstWhere(
                (c) => c['key'] == p.name,
              );
            } catch (_) {
              existingColumn = null;
            }
          }

          // S'assurer que label est toujours une Map valide
          Map<String, dynamic> label = existingColumn?['label'] ?? {
            'en': p.name,
            'fr': p.name,
          };

          return {
            'key': p.name,
            'label': label,
            'type': p.type,
            'alignment': existingColumn?['alignment'] ?? _getDefaultAlignment(p.type),
            'visible': existingColumn?['visible'] ?? true,
            'decimals': existingColumn?['decimals'] ?? (_isNumericType(p.type) ? 0 : null),
            'byteArrayType': existingColumn?['byteArrayType'] ?? (_isByteArrayType(p.type) ? 'Raw' : null),
          };
        }).toList();

        final newConfig = Map<String, dynamic>.from(widget.card.configuration);
        newConfig['dataSource'] = config.toJson()['dataSource'];
        newConfig['columns'] = _selectedColumns.map((col) => {
          'key': col['key'],
          'label': col['label'],
          'type': col['type'],
          'alignment': col['alignment'],
          'visible': col['visible'],
          'decimals': col['decimals'],
          'byteArrayType': col['byteArrayType'],
        }).toList();
        widget.onConfigurationChanged(newConfig);
      }
    });
  }

  void _loadAvailableProperties() {
    if (_dataSourceConfig.entitySchema != null) {
      setState(() {
        _availableColumns = _dataSourceConfig.entitySchema!.properties;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DataSourceSelector(
          initialConfiguration: _dataSourceConfig,
          onConfigurationChanged: _onDataSourceConfigurationChanged,
        ),
        const SizedBox(height: 16),
        if (_selectedColumns.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.columns,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _buildColumnsConfiguration(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColumnsConfiguration() {
    final l10n = AppLocalizations.of(context)!;
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedColumns.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _selectedColumns.removeAt(oldIndex);
          _selectedColumns.insert(newIndex, item);
        });
        _updateColumnConfiguration();
      },
      itemBuilder: (context, index) {
        final column = _selectedColumns[index];
        final columnKey = column['key'] as String;

        return StatefulBuilder(
          key: ValueKey(columnKey),
          builder: (context, setState) {
            return Column(
              children: [
                ListTile(
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                  title: Text(
                    (column['label'] as Map<String, dynamic>?)?['fr'] ?? 
                    column['key'] as String
                  ),
                  subtitle: Text('Type: ${column['type']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_expandedStates[columnKey] == true
                          ? Icons.expand_less
                          : Icons.expand_more),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _expandedStates[columnKey] = !(_expandedStates[columnKey] ?? false);
                    });
                  },
                ),
                if (_expandedStates[columnKey] == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Traductions
                        TranslationManager(
                          translations: column['label'],
                          onTranslationsChanged: (newTranslations) =>
                              _updateColumnTranslations(index, newTranslations),
                        ),
                        const SizedBox(height: 16),

                        // Alignement
                        DropdownButtonFormField<String>(
                          value: column['alignment'],
                          decoration: InputDecoration(
                            labelText: l10n.columnAlignment,
                            border: const OutlineInputBorder(),
                          ),
                          items: ['left', 'center', 'right']
                              .map((align) => DropdownMenuItem(
                                  value: align,
                                  child: Text(align == 'left'
                                      ? l10n.left
                                      : align == 'center'
                                          ? l10n.center
                                          : l10n.right)))
                              .toList(),
                          onChanged: (value) =>
                              _updateColumnAlignment(index, value!),
                        ),
                        const SizedBox(height: 16),

                        // Visibilité
                        Card(
                          child: SwitchListTile(
                            title: Text(l10n.columnVisibility),
                            value: column['visible'],
                            onChanged: (value) =>
                                _updateColumnVisibility(index, value),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Décimales
                        if (_isNumericType(column['type']))
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: l10n.decimals,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: column['decimals']?.toString(),
                            onChanged: (value) => _updateColumnDecimals(
                                index, int.tryParse(value)),
                          ),

                        // Type de Byte[]
                        if (_isByteArrayType(column['type']))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: column['byteArrayType'] ?? 'Raw',
                                decoration: InputDecoration(
                                  labelText: l10n.byteArrayType,
                                  border: const OutlineInputBorder(),
                                ),
                                items: ['Raw', 'Image']
                                    .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type)))
                                    .toList(),
                                onChanged: (value) => _updateByteArrayType(index, value!),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateColumnTranslations(
      int index, Map<String, String> newTranslations) {
    setState(() {
      // S'assurer que la colonne existe
      if (index < _selectedColumns.length) {
        _selectedColumns[index]['label'] = Map<String, String>.from(newTranslations);
      }
    });
    _updateColumnConfiguration();
  }

  void _updateColumnAlignment(int index, String value) {
    setState(() {
      _selectedColumns[index]['alignment'] = value;
    });
    _updateColumnConfiguration();
  }

  void _updateColumnVisibility(int index, bool value) {
    setState(() {
      _selectedColumns[index]['visible'] = value;
    });
    _updateColumnConfiguration();
  }

  void _updateColumnDecimals(int index, int? value) {
    setState(() {
      _selectedColumns[index]['decimals'] = value;
    });
    _updateColumnConfiguration();
  }

  void _updateByteArrayType(int index, String value) {
    setState(() {
      _selectedColumns[index]['byteArrayType'] = value;
    });
    _updateColumnConfiguration();
  }
}
