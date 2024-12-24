import 'package:flutter/material.dart';
import 'package:querier/models/dynamic_card.dart';
import 'package:querier/models/entity_schema.dart';
import 'package:querier/widgets/color_picker_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/services/data_context_service.dart';
import 'package:querier/api/api_client.dart';
import 'package:provider/provider.dart';
import 'package:querier/widgets/data_source_selector.dart';
import 'package:querier/utils/validators.dart';

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
  late DataSourceConfiguration _dataSourceConfig;

  @override
  void initState() {
    super.initState();
    config = Map<String, dynamic>.from(widget.card.configuration);
    
    // Initialiser la configuration par défaut
    if (!config.containsKey('lines')) {
      config['lines'] = [];
    }
    
    // S'assurer que nous avons un type de source de données
    if (!config.containsKey('type')) {
      config['type'] = DataSourceType.api.toString();
    }

    // Initialiser _dataSourceConfig
    _dataSourceConfig = DataSourceConfiguration(
      type: DataSourceType.values.firstWhere(
        (e) => e.toString() == config['type'],
        orElse: () => DataSourceType.api,
      ),
      context: config['context'],
      entity: config['entity'],
      entitySchema: config['entitySchema'] != null 
          ? EntitySchema.fromJson(config['entitySchema'])
          : null,
    );
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
                DataSourceSelector(
                  initialConfiguration: _dataSourceConfig,
                  onConfigurationChanged: (newConfig) {
                    setState(() {
                      _dataSourceConfig = newConfig;
                    });
                    final updatedConfig = Map<String, dynamic>.from(config);
                    updatedConfig.addAll(newConfig.toJson());
                    updateConfig(updatedConfig);
                  },
                ),
                const SizedBox(height: 16),
                // Pagination Settings
                SwitchListTile(
                  title: Text(l10n.enablePagination),
                  value: config['pagination'] ?? false,
                  onChanged: (value) {
                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['pagination'] = value;
                    updateConfig(newConfig);
                  },
                ),
                if (config['pagination'] ?? false)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.itemsPerPage,
                      helperText: l10n.invalidNumber,
                    ),
                    initialValue: (config['pageSize'] ?? 100).toString(),
                    keyboardType: TextInputType.number,
                    validator: (value) => validatePositiveInteger(value),
                    onChanged: (value) {
                      final newConfig = Map<String, dynamic>.from(config);
                      newConfig['pageSize'] = int.tryParse(value) ?? 100;
                      updateConfig(newConfig);
                    },
                  ),
                if (_dataSourceConfig.entitySchema != null) ...[
                  _buildLinesConfiguration(l10n),
                ],
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

  List<String> _getNumericFields() {
    if (_dataSourceConfig.entitySchema == null) return [];

    return _dataSourceConfig.entitySchema!.properties
        .where((prop) => _isNumericType(prop.type))
        .map((prop) => prop.name)
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
    if (_dataSourceConfig.entitySchema == null) return [];
    
    return _dataSourceConfig.entitySchema!.properties
        .map((prop) => prop.name)
        .toList();
  }

  Widget _buildLinesConfiguration(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.linesConfiguration,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...(config['lines'] as List<dynamic>).asMap().entries.map(
          (entry) {
            final index = entry.key;
            final line = entry.value as Map<String, dynamic>;
            return _buildLineConfig(index, line, l10n);
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.addNewLine),
          onPressed: () {
            final newConfig = Map<String, dynamic>.from(config);
            (newConfig['lines'] as List<dynamic>).add({
              'name': 'Line ${(config['lines'] as List).length + 1}',
              'dataField': null,
              'color': Colors.blue.value,
              'width': 2.0,
            });
            updateConfig(newConfig);
          },
        ),
      ],
    );
  }

  Widget _buildLineConfig(int index, Map<String, dynamic> line, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: l10n.lineName),
              initialValue: line['name'] as String?,
              onChanged: (value) {
                final newConfig = Map<String, dynamic>.from(config);
                (newConfig['lines'] as List<dynamic>)[index]['name'] = value;
                updateConfig(newConfig);
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: l10n.dataField),
              value: line['dataField'] as String?,
              items: _getNumericFields().map((field) {
                return DropdownMenuItem(value: field, child: Text(field));
              }).toList(),
              onChanged: (value) {
                final newConfig = Map<String, dynamic>.from(config);
                (newConfig['lines'] as List<dynamic>)[index]['dataField'] = value;
                updateConfig(newConfig);
              },
            ),
            const SizedBox(height: 8),
            ColorPickerButton(
              color: Color(line['color'] as int),
              onColorChanged: (color) {
                final newConfig = Map<String, dynamic>.from(config);
                (newConfig['lines'] as List<dynamic>)[index]['color'] = color!.value;
                updateConfig(newConfig);
              },
            ),
          ],
        ),
      ),
    );
  }
}

String? validatePositiveInteger(String? value) {
  if (value == null || value.isEmpty) return null;
  final n = int.tryParse(value);
  if (n == null || n <= 0) return 'Please enter a valid number greater than 0';
  return null;
}
