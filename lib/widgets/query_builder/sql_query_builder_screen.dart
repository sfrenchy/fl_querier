import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:querier/models/db_connection.dart';
import 'package:querier/models/db_schema.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/query_analysis.dart';
import 'package:querier/utils/sql_parser.dart';
import 'package:reorderables/reorderables.dart';
import 'package:resizable_widget/resizable_widget.dart';
import '../resizable_panel.dart';

class SQLQueryBuilderScreen extends StatefulWidget {
  final DBConnection database;
  final ApiClient apiClient;
  final String? initialQuery;

  const SQLQueryBuilderScreen({
    super.key,
    required this.database,
    required this.apiClient,
    this.initialQuery,
  });

  @override
  State<SQLQueryBuilderScreen> createState() => _SQLQueryBuilderScreenState();
}

class _SQLQueryBuilderScreenState extends State<SQLQueryBuilderScreen> {
  DatabaseSchema? _schema;
  bool _loading = true;
  String? _error;

  List<String> _selectedTables = [];
  final List<String> _selectedFields = [];
  final List<String> _conditions = [];

  late TextEditingController _queryController;

  // Ajout d'une variable pour stocker les objets analysés
  QueryAnalysis? _queryAnalysis;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _queryController =
        TextEditingController(text: widget.initialQuery ?? _buildMockQuery());

    // Parser la requête initiale si elle existe
    if (widget.initialQuery != null) {
      final parser = SQLParser(widget.initialQuery!);
      final tables = parser.extractTables();
      _selectedTables.addAll(tables);
    }

    _loadDatabaseSchema();

    // Ajouter un listener avec debounce pour analyser la requête
    _queryController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), _analyzeQuery);
    });

    // Si une requête initiale est fournie, l'analyser immédiatement
    if (widget.initialQuery != null) {
      _analyzeQuery();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _queryController.removeListener(_analyzeQuery);
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadDatabaseSchema() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final schema =
          await widget.apiClient.getDatabaseSchema(widget.database.id);

      print('Schema loaded:');
      print('Tables: ${schema.tables.length}');
      print('Views: ${schema.views.length}');
      print('Stored Procedures: ${schema.storedProcedures.length}');
      print('User Functions: ${schema.userFunctions.length}');

      setState(() {
        _schema = schema;
        _loading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading schema: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Nouvelle méthode pour analyser la requête
  Future<void> _analyzeQuery() async {
    if (_queryController.text.trim().isEmpty) return;

    try {
      print('Analyzing query: ${_queryController.text}'); // Debug log
      final analysis = await widget.apiClient.analyzeQuery(
        widget.database.id,
        _queryController.text,
      );

      print('Analysis result - Tables: ${analysis.tables}'); // Debug tables
      print('Analysis result - Views: ${analysis.views}'); // Debug views

      setState(() {
        _queryAnalysis = analysis;
        _selectedTables = [
          ...analysis.tables.map((t) => t.split('.').last),
          ...analysis.views.map((v) => v.split('.').last),
        ];
        print(
            'Selected tables after update: $_selectedTables'); // Debug final state
      });
    } catch (e) {
      print('Error analyzing query: $e');
    }
  }

  // Mettre à jour la requête quand les tables sont modifiées
  void _updateQuery() {
    if (!_queryController.text.startsWith('--')) {
      // Ne pas écraser une requête personnalisée
      setState(() {
        _queryController.text = _buildMockQuery();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $_error'),
              ElevatedButton(
                onPressed: _loadDatabaseSchema,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Constructeur de requêtes SQL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // TODO: Exécuter la requête
            },
            tooltip: 'Exécuter la requête',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // TODO: Sauvegarder la requête
            },
            tooltip: 'Sauvegarder la requête',
          ),
        ],
      ),
      body: Row(
        children: [
          ResizablePanel(
            key: const ValueKey('left_panel'),
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Objects',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        // Tables Section
                        ExpansionTile(
                          title: const Text('Tables'),
                          initiallyExpanded: true,
                          children: _schema?.tables
                                  .map((table) => ListTile(
                                        title: Text(table.name),
                                        subtitle: Text(table.schema),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              if (!_selectedTables
                                                  .contains(table.name)) {
                                                _selectedTables.add(table.name);
                                                _updateQuery(); // Mettre à jour la requête
                                              }
                                            });
                                          },
                                        ),
                                      ))
                                  .toList() ??
                              [],
                        ),

                        // Views Section
                        ExpansionTile(
                          title: const Text('Views'),
                          children: _schema?.views
                                  .map((view) => ListTile(
                                        title: Text(view.name),
                                        subtitle: Text(view.schema),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              if (!_selectedTables
                                                  .contains(view.name)) {
                                                _selectedTables.add(view.name);
                                                _updateQuery(); // Mettre à jour la requête
                                              }
                                            });
                                          },
                                        ),
                                      ))
                                  .toList() ??
                              [],
                        ),

                        // Stored Procedures Section
                        ExpansionTile(
                          title: const Text('Stored Procedures'),
                          children: _schema?.storedProcedures
                                  .map((proc) => ListTile(
                                        title: Text(proc.name),
                                        subtitle: Text(proc.schema),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            // TODO: Implémenter la logique pour les procédures stockées
                                          },
                                        ),
                                      ))
                                  .toList() ??
                              [],
                        ),

                        // User Functions Section
                        ExpansionTile(
                          title: const Text('User Functions'),
                          children: _schema?.userFunctions
                                  .map((func) => ListTile(
                                        title: Text(func.name),
                                        subtitle: Text(func.schema),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            // TODO: Implémenter la logique pour les fonctions
                                          },
                                        ),
                                      ))
                                  .toList() ??
                              [],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Zone principale de construction
          Expanded(
            key: const ValueKey('main_content'),
            child: Column(
              children: [
                // Zone de visualisation des tables sélectionnées
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Diagramme des relations',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              // Ici on afficherait le diagramme interactif
                              // Pour le mock, on affiche juste les tables sélectionnées
                              ..._selectedTables.map((table) => Positioned(
                                    left: 50.0 * _selectedTables.indexOf(table),
                                    top: 50.0 * _selectedTables.indexOf(table),
                                    child: Card(
                                      color: Colors.blue.shade100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              table,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Text('id: int'),
                                            const Text('name: string'),
                                            // Simuler quelques champs
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Zone de construction de la requête
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Requête SQL',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF282C34),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey.shade700,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _queryController,
                              style: const TextStyle(
                                fontFamily: 'ui-monospace',
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.5,
                              ),
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Panneau latéral droit - Options de requête
          SizedBox(
            key: const ValueKey('right_panel'),
            width: 250,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Options de requête',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text('Champs'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // TODO: Ajouter un champ
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Conditions'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // TODO: Ajouter une condition
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Tri'),
                    trailing: IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: () {
                        // TODO: Configurer le tri
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Groupement'),
                    trailing: IconButton(
                      icon: const Icon(Icons.group_work),
                      onPressed: () {
                        // TODO: Configurer le groupement
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildMockQuery() {
    if (_selectedTables.isEmpty) {
      return '-- Sélectionnez des tables pour construire la requête';
    }

    return '''
SELECT 
  ${_selectedTables.map((t) => '$t.*').join(', ')}
FROM 
  ${_selectedTables.join(' \nJOIN ')}
WHERE 
  -- Conditions seront ajoutées ici
ORDER BY 
  -- Tri sera ajouté ici
''';
  }
}
