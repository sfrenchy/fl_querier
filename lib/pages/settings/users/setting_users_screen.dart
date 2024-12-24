import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'bloc/users_bloc.dart';

class SettingUsersScreen extends StatefulWidget {
  const SettingUsersScreen({super.key});

  @override
  State<SettingUsersScreen> createState() => _SettingUsersScreenState();
}

class _SettingUsersScreenState extends State<SettingUsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(LoadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.users),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addUser,
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/users/form');
              if (result == true && mounted) {
                context.read<UsersBloc>().add(LoadUsers());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UsersError) {
            return Center(child: Text(state.message));
          }

          if (state is UsersLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    showCheckboxColumn: false,
                    columnSpacing: 24.0,
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Text(l10n.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(l10n.firstName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(l10n.email,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(l10n.emailStatus,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                    rows: state.users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user.lastName)),
                          DataCell(Text(user.firstName)),
                          DataCell(Text(user.email)),
                          DataCell(
                            Icon(
                              user.isEmailConfirmed
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color: user.isEmailConfirmed
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                        onSelectChanged: (_) async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/users/form',
                            arguments: user,
                          );
                          if (result == true && mounted) {
                            context.read<UsersBloc>().add(LoadUsers());
                          }
                        },
                      );
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
