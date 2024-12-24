import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/sql_query.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bloc/queries_bloc.dart';
import 'bloc/queries_event.dart';
import 'bloc/queries_state.dart';
import 'sql_query_form_screen.dart';

class QueriesScreen extends StatelessWidget {
  const QueriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    context.read<QueriesBloc>().add(LoadQueries());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.queries),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SQLQueryFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<QueriesBloc, QueriesState>(
        builder: (context, state) {
          if (state is QueriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QueriesError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is QueriesLoaded) {
            return Container(
              margin: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: state.queries.length,
                itemBuilder: (context, index) {
                  final query = state.queries[index];
                  return Card(
                    child: ListTile(
                      title: Text(query.name),
                      subtitle: Text(query.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SQLQueryFormScreen(query: query),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(context, query),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SQLQuery query) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteQuery),
        content: Text(l10n.deleteQueryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<QueriesBloc>().add(DeleteQuery(query.id));
    }
  }
}
