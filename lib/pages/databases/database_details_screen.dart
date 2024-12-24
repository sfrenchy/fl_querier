import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/models/db_connection.dart';

class DatabaseDetailsScreen extends StatelessWidget {
  final DBConnection connection;

  const DatabaseDetailsScreen({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(connection.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildInfoRow(l10n.name, connection.name),
              _buildInfoRow(l10n.apiRoute, connection.apiRoute),
              _buildInfoRow(l10n.databaseType, connection.type),
              _buildInfoRow(l10n.connectionString, connection.connectionString),
              _buildInfoRow(l10n.status,
                  connection.isActive ? l10n.active : l10n.inactive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
