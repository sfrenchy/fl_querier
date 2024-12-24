import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/sql_query.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/widgets/query_builder/sql_query_builder_screen.dart';
import '../../models/db_connection.dart';
import 'bloc/queries_bloc.dart';
import 'bloc/queries_event.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/sql.dart';

class SQLQueryFormScreen extends StatefulWidget {
  final SQLQuery? query;

  const SQLQueryFormScreen({super.key, this.query});

  @override
  State<SQLQueryFormScreen> createState() => _SQLQueryFormScreenState();
}

class _SQLQueryFormScreenState extends State<SQLQueryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late final controller = CodeController(
    text: widget.query?.query ?? '',
    language: sql,
  );
  bool _isPublic = false;
  int? _selectedConnectionId;

  final Map<String, dynamic> _sampleParameters = {};
  final _paramNameController = TextEditingController();
  final _paramValueController = TextEditingController();

  List<DBConnection> _connections = [];
  bool _isLoadingConnections = true;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.query?.name);
    _descriptionController =
        TextEditingController(text: widget.query?.description);
    _isPublic = widget.query?.isPublic ?? false;
    _selectedConnectionId = widget.query?.connectionId;

    print('Initial parameters from query: ${widget.query?.parameters}');

    if (widget.query?.parameters != null &&
        widget.query!.parameters.isNotEmpty) {
      setState(() {
        _sampleParameters.clear();
        _sampleParameters.addAll(widget.query!.parameters);
      });
    }

    print('Initialized sample parameters: $_sampleParameters');

    _loadConnections();
  }

  Future<void> _loadConnections() async {
    try {
      final connections = await context.read<ApiClient>().getDBConnections();
      setState(() {
        _connections = connections;
        _isLoadingConnections = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingConnections = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    controller.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.query != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editQuery : l10n.newQuery),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: l10n.save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.required;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _isLoadingConnections
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                      value: _selectedConnectionId,
                      decoration: InputDecoration(
                        labelText: l10n.database,
                        border: const OutlineInputBorder(),
                      ),
                      items: _connections
                          .map((conn) => DropdownMenuItem(
                                value: conn.id,
                                child: Text(conn.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedConnectionId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return l10n.required;
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        child: CodeField(
                          controller: controller,
                          textStyle: const TextStyle(
                            fontFamily: 'Fira Code',
                            fontSize: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          minLines: 1,
                          maxLines: null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.build),
                    tooltip: l10n.queryBuilder,
                    onPressed: _selectedConnectionId == null
                        ? null
                        : () {
                            final selectedDB = _connections.firstWhere(
                                (db) => db.id == _selectedConnectionId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SQLQueryBuilderScreen(
                                  database: selectedDB,
                                  apiClient: context.read<ApiClient>(),
                                  initialQuery: controller.text,
                                ),
                              ),
                            );
                          },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.isPublic),
                value: _isPublic,
                onChanged: (bool value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                l10n.testParameters,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildParametersSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParametersSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._sampleParameters.entries.map((entry) => Card(
              child: ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _sampleParameters.remove(entry.key);
                    });
                  },
                ),
              ),
            )),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _paramNameController,
                decoration: InputDecoration(
                  labelText: l10n.parameterName,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _paramValueController,
                decoration: InputDecoration(
                  labelText: l10n.parameterValue,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addParameter,
            ),
          ],
        ),
      ],
    );
  }

  void _addParameter() {
    final name = _paramNameController.text.trim();
    final value = _paramValueController.text.trim();

    if (name.isNotEmpty && value.isNotEmpty) {
      setState(() {
        _sampleParameters[name] = value;
        print('Added parameter: $_sampleParameters'); // Debug log
        _paramNameController.clear();
        _paramValueController.clear();
      });
    }
  }

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_selectedConnectionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.databaseRequired),
          ),
        );
        return;
      }

      print('Sample parameters before submit: $_sampleParameters'); // Debug log

      final query = SQLQuery(
        id: widget.query?.id ?? 0,
        name: _nameController.text,
        description: _descriptionController.text,
        query: controller.text,
        createdBy: widget.query?.createdBy ?? '',
        createdAt: widget.query?.createdAt ?? DateTime.now(),
        lastModifiedAt: DateTime.now(),
        isPublic: _isPublic,
        parameters: {},
        connectionId: _selectedConnectionId,
      );

      final params = Map<String, dynamic>.from(_sampleParameters);
      print('Copied parameters: $params'); // Debug log

      if (widget.query != null) {
        context.read<QueriesBloc>().add(
              UpdateQuery(query, sampleParameters: params),
            );
      } else {
        context.read<QueriesBloc>().add(
              AddQuery(query, sampleParameters: params),
            );
      }

      Navigator.pop(context);
    }
  }
}
