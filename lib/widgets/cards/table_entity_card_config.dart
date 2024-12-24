import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/cards/table_card.dart';
import 'package:provider/provider.dart';
import 'package:querier/models/entity_schema.dart';
import 'package:querier/widgets/translation_manager.dart';
import 'package:querier/services/data_context_service.dart';

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
  List<String> _contexts = [];
  List<EntitySchema> _entities = [];
  String? _selectedContext;
  String? _selectedEntity;
  bool _isLoading = true;
  List<Map<String, dynamic>> _selectedColumns = [];
  final Map<String, bool> _expandedStates = {};
  late final DataContextService _dataContextService;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dataContextService = context.read<ApiClient>().dataContextService;
      _initialized = true;
    }
    _loadContexts();
  }

  Future<void> _loadContexts() async {
    try {
      final contexts = await _dataContextService.getAvailableContexts();
      if (mounted) {
        setState(() {
          _contexts = contexts;
          _isLoading = false;
          _selectedContext = widget.card.configuration['context'] as String?;
          if (_selectedContext != null) {
            _loadEntities(_selectedContext!);
          }
        });
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }

  Future<void> _loadEntities(String context) async {
    try {
      final entities = await _dataContextService.getAvailableEntities(context);
      if (mounted) {
        setState(() {
          _entities = entities;
          _selectedEntity = widget.card.configuration['entity'] as String?;
          if (_selectedEntity != null) {
            _initializeColumns();
          }
        });
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }

  void _initializeColumns() {
    if (_selectedEntity != null) {
      final entity = _entities.firstWhere((e) => e.name == _selectedEntity);
      final existingColumns = widget.card.configuration['columns'] as List?;

      _selectedColumns = entity.properties.map((prop) {
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

        return {
          'name': prop.name,
          'key': prop.name,
          'type': prop.type,
          'translations': existingColumn?['label'] != null
              ? Map<String, String>.from(existingColumn!['label'] as Map)
              : {'en': prop.name, 'fr': prop.name},
          'alignment':
              existingColumn?['alignment'] ?? _getDefaultAlignment(prop.type),
          'visible': existingColumn?['visible'] ?? true,
          'decimals': existingColumn?['decimals'] ??
              (_isNumericType(prop.type) ? 0 : null),
        };
      }).toList();
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

  String _getDefaultAlignment(String type) {
    switch (type) {
      case "String?":
      case 'String':
        return 'left';
      case "DateTime?":
      case "DateTime":
        return 'right';
      case "Int32?":
      case 'Int32':
      case "Int16?":
      case 'Int16':
      case "Decimal?":
      case 'Decimal':
      case "Double?":
      case 'Double':
        return 'right';
      default:
        return 'center';
    }
  }

  void _updateColumnConfiguration() {
    final newConfig = Map<String, dynamic>.from(widget.card.configuration);
    newConfig['columns'] = _selectedColumns
        .map((col) => {
              'key': col['name'],
              'label': col['translations'],
              'alignment': col['alignment'],
              'visible': col['visible'],
              'decimals': col['decimals'],
            })
        .toList();
    widget.onConfigurationChanged(newConfig);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dataSource,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildContextSelector(),
                if (_selectedContext != null) _buildEntitySelector(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedEntity != null)
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

  Widget _buildContextSelector() {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButton<String>(
      value: _selectedContext,
      isExpanded: true,
      hint: Text(l10n.selectDataContext),
      items: _contexts
          .map(
            (context) => DropdownMenuItem(
              value: context,
              child: Text(context),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedContext = value;
          _selectedEntity = null;
          _entities.clear();
        });
        if (value != null) {
          _loadEntities(value);
          final newConfig =
              Map<String, dynamic>.from(widget.card.configuration);
          newConfig['context'] = value;
          widget.onConfigurationChanged(newConfig);
        }
      },
    );
  }

  Widget _buildEntitySelector() {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButton<String>(
      value: _selectedEntity,
      isExpanded: true,
      hint: Text(l10n.selectEntity),
      items: _entities
          .map(
            (entity) => DropdownMenuItem(
              value: entity.name,
              child: Text(entity.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() => _selectedEntity = value);
        if (value != null) {
          final entity = _entities.firstWhere((e) => e.name == value);
          final newConfig =
              Map<String, dynamic>.from(widget.card.configuration);
          newConfig['entity'] = value;
          newConfig['entitySchema'] = entity.toJson();

          // Initialiser les colonnes par défaut
          newConfig['columns'] = entity.properties
              .map((prop) => {
                    'key': prop.name,
                    'label': {'en': prop.name, 'fr': prop.name},
                    'alignment': _getDefaultAlignment(prop.type),
                    'visible': true,
                    'decimals': _isNumericType(prop.type) ? 0 : null,
                  })
              .toList();

          widget.onConfigurationChanged(newConfig);
          _initializeColumns(); // Mettre à jour l'interface
        }
      },
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
        final columnKey = column['name'] as String;

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
                  title: Text(column['name']),
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
                    this.setState(() {
                      _expandedStates[columnKey] =
                          !(_expandedStates[columnKey] ?? false);
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
                          translations: column['translations'],
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
      _selectedColumns[index]['translations'] = newTranslations;
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
}
