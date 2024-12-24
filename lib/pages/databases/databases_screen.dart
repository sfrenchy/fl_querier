import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/db_connection.dart';
import 'bloc/databases_bloc.dart';

class DatabasesScreen extends StatelessWidget {
  const DatabasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) =>
          DatabasesBloc(context.read<ApiClient>())..add(LoadDatabases()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.databases),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/databases/form'),
            ),
          ],
        ),
        body: BlocBuilder<DatabasesBloc, DatabasesState>(
          builder: (context, state) {
            if (state is DatabasesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DatabasesError) {
              return Center(child: Text(state.message));
            }

            if (state is DatabasesLoaded) {
              return ListView.builder(
                itemCount: state.connections.length,
                itemBuilder: (context, index) {
                  final connection = state.connections[index];
                  return _buildConnectionCard(context, connection);
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildConnectionCard(BuildContext context, DBConnection connection) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(
          Icons.storage,
          color: connection.isActive ? Colors.green : Colors.grey,
        ),
        title: Text(connection.name),
        subtitle: Text('/${connection.apiRoute}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: connection.isActive,
              onChanged: (value) {
                context
                    .read<DatabasesBloc>()
                    .add(ToggleDatabaseStatus(connection.id, value));
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => Navigator.pushNamed(
                context,
                '/databases/details',
                arguments: connection,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, connection),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, DBConnection connection) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDatabase),
        content: Text(l10n.deleteDatabaseConfirmation),
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
      context.read<DatabasesBloc>().add(DeleteDatabase(connection.id));
    }
  }
}
