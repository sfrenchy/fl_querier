import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'bloc/roles_bloc.dart';

class SettingRolesScreen extends StatefulWidget {
  const SettingRolesScreen({super.key});

  @override
  State<SettingRolesScreen> createState() => _SettingRolesScreenState();
}

class _SettingRolesScreenState extends State<SettingRolesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RolesBloc>().add(LoadRoles());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.roles),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addRole,
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/roles/form');
              if (result == true) {
                if (!context.mounted) return;
                context.read<RolesBloc>().add(LoadRoles());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<RolesBloc, RolesState>(
        builder: (context, state) {
          if (state is RolesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RolesError) {
            return Center(child: Text(state.message));
          }

          if (state is RolesLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: 24.0,
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Text(l10n.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                    rows: state.roles.map((role) {
                      return DataRow(cells: [
                        DataCell(
                          Text(role.name),
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/roles/form',
                              arguments: role, // Passer le rôle à modifier
                            );
                            if (result == true) {
                              if (!context.mounted) return;
                              context.read<RolesBloc>().add(LoadRoles());
                            }
                          },
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
