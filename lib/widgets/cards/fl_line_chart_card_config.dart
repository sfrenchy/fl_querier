import 'package:flutter/material.dart';
import 'package:querier/models/dynamic_card.dart';
import 'package:querier/models/entity_schema.dart';
import 'package:querier/widgets/color_picker_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/services/data_context_service.dart';
import 'package:querier/api/api_client.dart';
import 'package:provider/provider.dart';

enum DataSourceType { api, contextEntity }

class FLLineChartCardConfig extends StatefulWidget {
  final DynamicCard card;
  final ValueChanged<Map<String, dynamic>> onConfigurationChanged;

  const FLLineChartCardConfig({
    super.key,
    required this.card,
    required this.onConfigurationChanged,
  });

  @override
  State<FLLineChartCardConfig> createState() => _FLLineChartCardConfigState();
}

class _FLLineChartCardConfigState extends State<FLLineChartCardConfig> {
  late final Map<String, dynamic> config;
  Map<String, dynamic>? previewData;
  late final DataContextService _dataContextService;
  List<String> _contexts = [];
  List<EntitySchema> _entities = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dataContextService = DataContextService(context.read<ApiClient>());
      config = Map<String, dynamic>.from(widget.card.configuration);
      if (!config.containsKey('lines')) {
        config['lines'] = [];
        Future.microtask(() {
          widget.onConfigurationChanged(config);
        });
      }
      config['dataSourceType'] ??= DataSourceType.api.toString();

      final savedContext = config['dataContext'] as String?;
      if (savedContext != null) {
        _loadEntities(savedContext).then((_) {
          if (config['entity'] != null) {
            _loadPreviewData();
          }
        });
      }

      _initialized = true;
    }
    _loadContexts();
  }

  Future<void> _loadContexts() async {
    final contexts = await _dataContextService.getAvailableContexts();
    setState(() {
      _contexts = contexts;
    });
  }

  Future<void> _loadEntities(String context) async {
    final entities = await _dataContextService.getAvailableEntities(context);
    setState(() {
      _entities = entities;
    });
  }

  void updateConfig(Map<String, dynamic> newConfig) {
    setState(() {
      config.clear();
      config.addAll(newConfig);
    });
    widget.onConfigurationChanged(newConfig);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Source Section
            ExpansionTile(
              title: Text(l10n.dataSource),
              initiallyExpanded: true,
              children: [
                DropdownButtonFormField<DataSourceType>(
                  decoration: InputDecoration(
                    labelText: "Data Source Type", //l10n.dataSourceType,
                  ),
                  value: DataSourceType.values.firstWhere(
                    (e) => e.toString() == config['dataSourceType'],
                    orElse: () => DataSourceType.api,
                  ),
                  items: DataSourceType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type == DataSourceType.api
                          ? l10n.apiEndpoint
                          : "Context/Entity"), //l10n.contextEntity),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['dataSourceType'] = value.toString();
                    updateConfig(newConfig);
                  },
                ),
                const SizedBox(height: 16),
                if (config['dataSourceType'] ==
                    DataSourceType.api.toString()) ...[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.apiEndpoint,
                      helperText: l10n.urlToFetchData,
                    ),
                    initialValue: (config['dataSource'] as String?) ?? '',
                    onChanged: (value) {
                      final newConfig = Map<String, dynamic>.from(config);
                      newConfig['dataSource'] = value;
                      updateConfig(newConfig);
                    },
                  ),
                ] else ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.dataContext,
                    ),
                    value: config['dataContext'] as String?,
                    items: _getAvailableContexts().map((context) {
                      return DropdownMenuItem(
                        value: context,
                        child: Text(context),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final newConfig = Map<String, dynamic>.from(config);
                      newConfig['dataContext'] = value;
                      updateConfig(newConfig);
                      if (value != null) {
                        _loadEntities(value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  if (config['dataContext'] != null)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: l10n.entity,
                      ),
                      value: config['entity'] as String?,
                      items: _getAvailableEntities(config['dataContext'])
                          .map((entity) {
                        return DropdownMenuItem(
                          value: entity,
                          child: Text(entity),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final newConfig = Map<String, dynamic>.from(config);
                        newConfig['entity'] = value;
                        updateConfig(newConfig);
                        _loadPreviewData();
                      },
                    ),
                  if (config['dataContext'] != null &&
                      config['entity'] != null) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: l10n.orderBy,
                      ),
                      value: config['orderBy'] as String?,
                      items: _getAllFields().map((field) {
                        return DropdownMenuItem(
                          value: field,
                          child: Text(field),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final newConfig = Map<String, dynamic>.from(config);
                        newConfig['orderBy'] = value;
                        updateConfig(newConfig);
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.refreshInterval,
                    helperText: l10n.dataRefreshFrequency,
                  ),
                  initialValue: (config['refreshInterval'] as String?) ?? '60',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['refreshInterval'] = int.tryParse(value) ?? 60;
                    updateConfig(newConfig);
                  },
                ),
                if (previewData != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.preview,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          ...previewData!.entries.map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '${entry.key}: ${entry.value}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
                Column(
                  children: [
                    // Ajouter le switch pour la pagination
                    SwitchListTile(
                      title:
                          Text(AppLocalizations.of(context)!.enablePagination),
                      value:
                          (widget.card.configuration['pagination'] as bool?) ??
                              false,
                      onChanged: (bool value) {
                        setState(() {
                          widget.card.configuration['pagination'] = value;
                          widget.onConfigurationChanged(
                              widget.card.configuration);
                        });
                      },
                    ),

                    // Afficher le champ de saisie du nombre d'éléments par page uniquement si la pagination est activée
                    if (widget.card.configuration['pagination'] == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .itemsPerPage,
                                ),
                                initialValue:
                                    ((widget.card.configuration['pageSize']
                                                as int?) ??
                                            100)
                                        .toString(),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .required;
                                  }
                                  final number = int.tryParse(value);
                                  if (number == null || number <= 0) {
                                    return AppLocalizations.of(context)!
                                        .invalidNumber;
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final number = int.tryParse(value);
                                  if (number != null && number > 0) {
                                    widget.card.configuration['pageSize'] =
                                        number;
                                    widget.onConfigurationChanged(
                                        widget.card.configuration);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Axes Configuration
            ExpansionTile(
              title: Text(l10n.axesConfiguration),
              children: [
                // X Axis
                Text(l10n.xAxis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                SwitchListTile(
                  title: Text(l10n.showGridLines),
                  value: config['xAxisShowGrid'] ?? true,
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['xAxisShowGrid'] = value;
                    updateConfig(newConfig);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.axisLabel,
                  ),
                  initialValue: (config['xAxisLabel'] as String?) ?? '',
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['xAxisLabel'] = value;
                    updateConfig(newConfig);
                  },
                ),
                // Ajouter le dropdown pour la colonne des libellés X
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.xAxisLabelField,
                  ),
                  value: config['xAxisLabelField'] as String?,
                  items: _getAllFields().map((field) {
                    return DropdownMenuItem(
                      value: field,
                      child: Text(field),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['xAxisLabelField'] = value;
                    updateConfig(newConfig);
                  },
                ),

                // Y Axis
                Text(l10n.yAxis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                SwitchListTile(
                  title: Text(l10n.showGridLines),
                  value: config['yAxisShowGrid'] ?? true,
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['yAxisShowGrid'] = value;
                    updateConfig(newConfig);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.axisLabel,
                  ),
                  initialValue: (config['yAxisLabel'] as String?) ?? '',
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['yAxisLabel'] = value;
                    updateConfig(newConfig);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n.minValue,
                        ),
                        initialValue: (config['yAxisMin'] as String?) ?? '',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newConfig = Map<String, dynamic>.from(config);
                          newConfig['yAxisMin'] = double.tryParse(value);
                          updateConfig(newConfig);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n.maxValue,
                        ),
                        initialValue: (config['yAxisMax'] as String?) ?? '',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newConfig = Map<String, dynamic>.from(config);
                          newConfig['yAxisMax'] = double.tryParse(value);
                          updateConfig(newConfig);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Multi-Line Configuration
            ExpansionTile(
              title: Text(l10n.linesConfiguration),
              children: [
                // Liste des lignes configurées
                ..._buildLinesList(config),

                // Bouton pour ajouter une nouvelle ligne
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addNewLine),
                  onPressed: () {
                    final newConfig = Map<String, dynamic>.from(config);
                    final lines = List<Map<String, dynamic>>.from(
                      newConfig['lines'] ?? [],
                    );
                    lines.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': 'New Line ${lines.length + 1}',
                      'color': Colors.blue.value,
                      'width': 2.0,
                      'dataField': '',
                      'showDots': true,
                      'isCurved': false,
                    });
                    newConfig['lines'] = lines;
                    updateConfig(newConfig);
                  },
                ),
              ],
            ),

            // Tooltip Configuration
            ExpansionTile(
              title: Text(l10n.tooltipSettings),
              children: [
                SwitchListTile(
                  title: Text(l10n.showTooltip),
                  value: config['showTooltip'] ?? true,
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['showTooltip'] = value;
                    updateConfig(newConfig);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.tooltipFormat,
                    helperText: l10n.tooltipFormatExample('{value}'),
                  ),
                  initialValue:
                      config['tooltipFormat']?.toString() ?? '{value}',
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['tooltipFormat'] = value;
                    updateConfig(newConfig);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLinesList(Map<String, dynamic> config) {
    final lines = List<Map<String, dynamic>>.from(config['lines'] ?? []);
    return lines.map((line) => _buildLineItem(line, config)).toList();
  }

  Widget _buildLineItem(
      Map<String, dynamic> line, Map<String, dynamic> config) {
    final l10n = AppLocalizations.of(context)!;
    final numericFields = _getNumericFields();
    final currentValue = line['dataField'] as String?;

    // Vérifier si la valeur actuelle existe dans les champs numériques
    final validValue =
        currentValue != null && numericFields.contains(currentValue)
            ? currentValue
            : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.lineName,
                    ),
                    initialValue: (line['name'] as String?) ?? '',
                    onChanged: (value) {
                      final newConfig = Map<String, dynamic>.from(config);
                      final lines = List<Map<String, dynamic>>.from(
                          newConfig['lines'] ?? []);
                      final lineIndex =
                          lines.indexWhere((l) => l['id'] == line['id']);
                      if (lineIndex != -1) {
                        lines[lineIndex] = Map<String, dynamic>.from(line)
                          ..['name'] = value;
                        newConfig['lines'] = lines;
                        updateConfig(newConfig);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final newConfig = Map<String, dynamic>.from(config);
                    final lines = List<Map<String, dynamic>>.from(
                        newConfig['lines'] ?? []);
                    lines.removeWhere((l) => l['id'] == line['id']);
                    newConfig['lines'] = lines;
                    updateConfig(newConfig);
                  },
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.dataField,
                helperText: l10n.jsonFieldPath,
              ),
              value: validValue,
              items: numericFields.map((field) {
                return DropdownMenuItem(
                  value: field,
                  child: Text(field),
                );
              }).toList(),
              onChanged: (value) {
                final newConfig = Map<String, dynamic>.from(config);
                final lines =
                    List<Map<String, dynamic>>.from(newConfig['lines'] ?? []);
                final lineIndex =
                    lines.indexWhere((l) => l['id'] == line['id']);
                if (lineIndex != -1) {
                  lines[lineIndex] = Map<String, dynamic>.from(line)
                    ..['dataField'] = value;
                  newConfig['lines'] = lines;
                  updateConfig(newConfig);
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ColorPickerButton(
                    color: Color(line['color'] ?? Colors.blue.value),
                    onColorChanged: (color) {
                      final newConfig = Map<String, dynamic>.from(config);
                      final lines = List<Map<String, dynamic>>.from(
                          newConfig['lines'] ?? []);
                      final lineIndex =
                          lines.indexWhere((l) => l['id'] == line['id']);
                      if (lineIndex != -1) {
                        lines[lineIndex] = Map<String, dynamic>.from(line)
                          ..['color'] = color!.value;
                        newConfig['lines'] = lines;
                        updateConfig(newConfig);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.lineWidth,
                    ),
                    initialValue:
                        (line['width']?.toString() as String?) ?? '2.0',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final newConfig = Map<String, dynamic>.from(config);
                      final lines = List<Map<String, dynamic>>.from(
                          newConfig['lines'] ?? []);
                      final lineIndex =
                          lines.indexWhere((l) => l['id'] == line['id']);
                      if (lineIndex != -1) {
                        lines[lineIndex] = Map<String, dynamic>.from(line)
                          ..['width'] = double.tryParse(value) ?? 2.0;
                        newConfig['lines'] = lines;
                        updateConfig(newConfig);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableContexts() => _contexts;
  List<String> _getAvailableEntities(String? context) =>
      _entities.map((e) => e.name).toList();

  Future<void> _loadPreviewData() async {
    if (config['dataContext'] == null || config['entity'] == null) return;

    try {
      final preview = await _dataContextService.getEntityPreview(
        config['dataContext'] as String,
        config['entity'] as String,
      );

      if (mounted) {
        setState(() {
          previewData = preview;
        });
      }
    } catch (e) {
      print('Error loading preview data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading preview data: $e')),
        );
      }
    }
  }

  List<String> _getNumericFields() {
    if (previewData == null) return [];

    return previewData!.entries
        .where((entry) => _isNumericType(entry.value))
        .map((entry) => entry.key)
        .toList();
  }

  bool _isNumericType(String type) {
    return [
      'Int32',
      'Int16',
      'Decimal',
      'Double',
      'Single',
      'Int32?',
      'Int16?',
      'Decimal?',
      'Double?',
      'Single?'
    ].contains(type);
  }

  List<String> _getAllFields() {
    if (previewData == null) return [];
    return previewData!.entries.map((entry) => entry.key).toList();
  }
}
