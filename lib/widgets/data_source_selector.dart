import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/entity_schema.dart';
import 'package:querier/models/db_connection.dart';
import 'package:querier/services/data_context_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

enum DataSourceType { api, entity, query }

class DataSourceConfiguration {
  final DataSourceType type;
  final String? apiEndpoint;
  final String? context;
  final String? entity;
  final String? query;
  final EntitySchema? entitySchema;
  final int? selectedDbConnectionId;
  final String? selectedController;
  final ControllerInfoResponse? controller;

  DataSourceConfiguration({
    required this.type,
    this.apiEndpoint,
    this.context,
    this.entity,
    this.query,
    this.entitySchema,
    this.selectedDbConnectionId,
    this.selectedController,
    this.controller,
  });

  Future<(List<dynamic>, int)> fetchData(
    ApiClient apiClient, {
    int pageNumber = 1,
    int pageSize = 0,
    String orderBy = '',
  }) async {
    switch (type) {
      case DataSourceType.api:
        if (selectedDbConnectionId == null || controller == null)
          return ([], 0);
        final response = await apiClient.get(
          controller!.route,
          queryParameters: {
            'PageNumber': pageNumber,
            'PageSize': pageSize,
          },
        );
        final data = response.data as Map<String, dynamic>;
        return (data['Items'] as List, data['Total'] as int);

      case DataSourceType.entity:
        if (context == null || entity == null) return ([], 0);
        return apiClient.getEntityData(
          context!,
          entity!,
          pageNumber: pageNumber,
          pageSize: pageSize,
          orderBy: orderBy,
        );

      case DataSourceType.query:
        if (query == null) return ([], 0);
        return apiClient.executeQuery(
          query!,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
    }
  }

  Map<String, dynamic> toJson() => {
        'dataSource': {
          'type': type.name,
          'query': query,
          'context': context,
          'entity': entity,
          'selectedDbConnectionId': selectedDbConnectionId,
          'selectedController': selectedController,
          if (controller != null)
            'controller': {
              'Name': controller!.name,
              'Route': controller!.route,
              'HttpGetJsonSchema': controller!.httpGetJsonSchema,
            },
        },
      };

  factory DataSourceConfiguration.fromJson(Map<String, dynamic> json) {
    final dataSource = json['dataSource'] as Map<String, dynamic>?;
    if (dataSource != null) {
      final typeStr = dataSource['type'] as String?;
      final type = typeStr != null
          ? DataSourceType.values.firstWhere(
              (t) => t.name.toLowerCase() == typeStr.toLowerCase(),
              orElse: () => DataSourceType.api,
            )
          : DataSourceType.api;

      return DataSourceConfiguration(
        type: type,
        query: dataSource['query'] as String?,
        context: dataSource['context'] as String?,
        entity: dataSource['entity'] as String?,
        entitySchema: json['entitySchema'] != null
            ? EntitySchema.fromJson(json['entitySchema'])
            : null,
        selectedDbConnectionId: dataSource['selectedDbConnectionId'] as int?,
        selectedController: dataSource['selectedController'] as String?,
        controller: dataSource['controller'] != null
            ? ControllerInfoResponse.fromJson(dataSource['controller'])
            : null,
      );
    }

    return DataSourceConfiguration(type: DataSourceType.api);
  }

  DataSourceConfiguration copyWith({
    DataSourceType? type,
    String? context,
    String? entity,
    EntitySchema? entitySchema,
    String? query,
    int? selectedDbConnectionId,
    String? selectedController,
    ControllerInfoResponse? controller,
  }) {
    return DataSourceConfiguration(
      type: type ?? this.type,
      context: context ?? this.context,
      entity: entity ?? this.entity,
      entitySchema: entitySchema ?? this.entitySchema,
      query: query ?? this.query,
      selectedDbConnectionId:
          selectedDbConnectionId ?? this.selectedDbConnectionId,
      selectedController: selectedController ?? this.selectedController,
      controller: controller ?? this.controller,
    );
  }
}

class DataSourceSelector extends StatefulWidget {
  final DataSourceConfiguration? initialConfiguration;
  final void Function(DataSourceConfiguration) onConfigurationChanged;

  const DataSourceSelector({
    super.key,
    this.initialConfiguration,
    required this.onConfigurationChanged,
  });

  @override
  State<DataSourceSelector> createState() => _DataSourceSelectorState();
}

class _DataSourceSelectorState extends State<DataSourceSelector> {
  late DataSourceConfiguration _config;
  List<String> _contexts = [];
  List<EntitySchema> _entities = [];
  List<String> _queries = [];
  List<DBConnection> _dbConnections = [];
  List<ControllerInfoResponse> _controllers = [];
  bool _isLoading = true;
  DataContextService? _dataContextService;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfiguration ??
        DataSourceConfiguration(type: DataSourceType.api);
    _loadQueries();
    _loadDBConnections();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dataContextService == null) {
      _dataContextService = context.read<ApiClient>().dataContextService;
      _loadContexts();
    }
  }

  Future<void> _loadContexts() async {
    try {
      final contexts = await _dataContextService!.getAvailableContexts();
      if (mounted) {
        setState(() {
          _contexts = contexts;
          _isLoading = false;
        });
        if (_config.context != null) {
          _loadEntities(_config.context!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contexts: $e')),
        );
      }
    }
  }

  Future<void> _loadEntities(String context) async {
    try {
      final entities = await _dataContextService!.getAvailableEntities(context);
      if (mounted) {
        setState(() {
          _entities = entities;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Error loading entities: $e')),
        );
      }
    }
  }

  Future<void> _loadQueries() async {
    try {
      final apiClient = context.read<ApiClient>();
      final queries = await apiClient.getSQLQueries();
      if (mounted) {
        setState(() {
          _queries = queries.map((q) => q.name).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading queries: $e');
    }
  }

  Future<void> _loadDBConnections() async {
    try {
      final apiClient = context.read<ApiClient>();
      final connections = await apiClient.getDBConnections();
      if (mounted) {
        setState(() {
          _dbConnections = connections;
        });
        if (_config.selectedDbConnectionId != null) {
          _loadControllers(_config.selectedDbConnectionId!);
        }
      }
    } catch (e) {
      debugPrint('Error loading DB connections: $e');
    }
  }

  Future<void> _loadControllers(int connectionId) async {
    try {
      final apiClient = context.read<ApiClient>();
      final controllers =
          await apiClient.getDBConnectionControllers(connectionId);
      if (mounted) {
        setState(() {
          _controllers = controllers;
        });
      }
    } catch (e) {
      debugPrint('Error loading controllers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dataSource,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            DropdownButtonFormField<DataSourceType>(
              value: _config.type,
              decoration: InputDecoration(
                labelText: l10n.dataSourceType,
                border: const OutlineInputBorder(),
              ),
              items: DataSourceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getDataSourceTypeLabel(type, l10n)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _config = DataSourceConfiguration(type: value);
                  });
                  widget.onConfigurationChanged(_config);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildDataSourceSpecificFields(l10n),
          ],
        ),
      ),
    );
  }

  String _getDataSourceTypeLabel(DataSourceType type, AppLocalizations l10n) {
    switch (type) {
      case DataSourceType.api:
        return l10n.apiEndpoint;
      case DataSourceType.entity:
        return l10n.entity;
      case DataSourceType.query:
        return l10n.query;
    }
  }

  Widget _buildDataSourceSpecificFields(AppLocalizations l10n) {
    switch (_config.type) {
      case DataSourceType.api:
        return Column(
          children: [
            DropdownButtonFormField<int>(
              value: _config.selectedDbConnectionId,
              decoration: InputDecoration(
                labelText: l10n.dbConnection,
                border: const OutlineInputBorder(),
              ),
              items: _dbConnections.map((conn) {
                return DropdownMenuItem(
                  value: conn.id,
                  child: Text(conn.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _config = _config.copyWith(
                      selectedDbConnectionId: value,
                      selectedController: null,
                    );
                  });
                  _loadControllers(value);
                  widget.onConfigurationChanged(_config);
                }
              },
            ),
            if (_config.selectedDbConnectionId != null) ...[
              const SizedBox(height: 16),
              if (_controllers.isNotEmpty)
                DropdownButtonFormField<ControllerInfoResponse>(
                  value: _controllers.firstWhere(
                    (c) => c.name == _config.selectedController,
                    orElse: () => _controllers[0],
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.controller,
                    border: const OutlineInputBorder(),
                  ),
                  items: _controllers.map((controller) {
                    return DropdownMenuItem(
                      value: controller,
                      child: Text(controller.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _onControllerSelected(value);
                    }
                  },
                ),
            ],
          ],
        );

      case DataSourceType.entity:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: _config.context,
              decoration: InputDecoration(
                labelText: l10n.dataContext,
                border: const OutlineInputBorder(),
              ),
              items: _contexts.map((context) {
                return DropdownMenuItem(
                  value: context,
                  child: Text(context),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _config = DataSourceConfiguration(
                      type: DataSourceType.entity,
                      context: value,
                    );
                  });
                  _loadEntities(value);
                  widget.onConfigurationChanged(_config);
                }
              },
            ),
            if (_config.context != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _config.entity,
                decoration: InputDecoration(
                  labelText: l10n.entity,
                  border: const OutlineInputBorder(),
                ),
                items: _entities.map((entity) {
                  return DropdownMenuItem(
                    value: entity.name,
                    child: Text(entity.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final entitySchema = _entities.firstWhere(
                      (e) => e.name == value,
                    );
                    _config = DataSourceConfiguration(
                      type: DataSourceType.entity,
                      context: _config.context,
                      entity: value,
                      entitySchema: entitySchema,
                    );
                    widget.onConfigurationChanged(_config);
                  }
                },
              ),
            ],
          ],
        );

      case DataSourceType.query:
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.selectQuery,
            border: const OutlineInputBorder(),
          ),
          value: _config.query,
          items: _queries.map((query) {
            return DropdownMenuItem(
              value: query,
              child: Text(query),
            );
          }).toList(),
          onChanged: (value) async {
            if (value != null) {
              final apiClient = context.read<ApiClient>();
              final queries = await apiClient.getSQLQueries();
              final selectedQuery = queries.firstWhere((q) => q.name == value);

              if (selectedQuery.outputDescription != null) {
                final schema = EntitySchema.fromJson(
                    jsonDecode(selectedQuery.outputDescription!)
                        as Map<String, dynamic>);

                _config = DataSourceConfiguration(
                  type: DataSourceType.query,
                  context: 'Query',
                  entity: selectedQuery.id.toString(),
                  query: value,
                  entitySchema: schema,
                );
                widget.onConfigurationChanged(_config);
              }
            }
          },
        );
    }
  }

  void _onControllerSelected(ControllerInfoResponse controller) {
    setState(() {
      _config = _config.copyWith(
        type: DataSourceType.api,
        selectedController: controller.name,
        controller: controller,
      );
    });
    widget.onConfigurationChanged(_config);
  }
}
