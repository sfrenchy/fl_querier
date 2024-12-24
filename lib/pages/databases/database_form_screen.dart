import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/db_connection.dart';
import 'bloc/database_form_bloc.dart';

class DatabaseFormScreen extends StatefulWidget {
  final DBConnection? connectionToEdit;

  const DatabaseFormScreen({super.key, this.connectionToEdit});

  @override
  State<DatabaseFormScreen> createState() => _DatabaseFormScreenState();
}

class _DatabaseFormScreenState extends State<DatabaseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => DatabaseFormBloc(context.read<ApiClient>()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.connectionToEdit != null
              ? l10n.editDatabase
              : l10n.addDatabase),
        ),
        body: BlocConsumer<DatabaseFormBloc, DatabaseFormState>(
          listener: (context, state) {
            if (state is DatabaseFormSuccess) {
              Navigator.pop(context);
            } else if (state is DatabaseFormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildNameField(context),
                    const SizedBox(height: 16),
                    _buildConnectionStringField(context),
                    const SizedBox(height: 16),
                    _buildApiRouteField(context),
                    const SizedBox(height: 16),
                    _buildConnectionTypeDropdown(context),
                    const SizedBox(height: 16),
                    _buildGenerateProceduresSwitch(context),
                    const SizedBox(height: 24),
                    _buildSubmitButton(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      initialValue: widget.connectionToEdit?.name,
      decoration: InputDecoration(
        labelText: l10n.name,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty ?? true ? l10n.fieldRequired : null,
      onSaved: (value) =>
          context.read<DatabaseFormBloc>().add(NameChanged(value ?? '')),
    );
  }

  Widget _buildConnectionStringField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      initialValue: widget.connectionToEdit?.connectionString,
      decoration: InputDecoration(
        labelText: l10n.connectionString,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty ?? true ? l10n.fieldRequired : null,
      onSaved: (value) => context
          .read<DatabaseFormBloc>()
          .add(ConnectionStringChanged(value ?? '')),
    );
  }

  Widget _buildApiRouteField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      initialValue: widget.connectionToEdit?.apiRoute,
      decoration: InputDecoration(
        labelText: l10n.apiRoute,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty ?? true ? l10n.fieldRequired : null,
      onSaved: (value) =>
          context.read<DatabaseFormBloc>().add(ApiRouteChanged(value ?? '')),
    );
  }

  Widget _buildConnectionTypeDropdown(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.databaseType,
        border: const OutlineInputBorder(),
      ),
      value: widget.connectionToEdit?.type ?? 'MySQL',
      items: ['SqlServer', 'MySQL', 'PgSQL']
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) => context
          .read<DatabaseFormBloc>()
          .add(ConnectionTypeChanged(value ?? 'MySQL')),
    );
  }

  Widget _buildGenerateProceduresSwitch(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DatabaseFormBloc, DatabaseFormState>(
      buildWhen: (previous, current) =>
          previous.generateProcedures != current.generateProcedures,
      builder: (context, state) {
        return SwitchListTile(
          title: Text(l10n.generateProcedures),
          value: state.generateProcedures,
          onChanged: (value) => context
              .read<DatabaseFormBloc>()
              .add(GenerateProceduresChanged(value)),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, DatabaseFormState state) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSubmitting
            ? null
            : () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  context.read<DatabaseFormBloc>().add(FormSubmitted());
                }
              },
        child: Text(l10n.add),
      ),
    );
  }
}
