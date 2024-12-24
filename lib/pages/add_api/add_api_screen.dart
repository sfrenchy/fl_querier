import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/pages/login/login_bloc.dart';
import 'add_api_bloc.dart';

class AddApiScreen extends StatelessWidget {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _urlPathController = TextEditingController();

  AddApiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => AddApiBloc(),
      child: BlocConsumer<AddApiBloc, AddApiState>(
        listener: (context, state) {
          if (state is AddApiSuccess) {
            context.read<LoginBloc>().add(LoadSavedUrls());
            Navigator.pop(context);
          } else if (state is AddApiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.addApi),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    context.read<AddApiBloc>().add(SaveApiUrl());
                  },
                ),
              ],
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProtocolSelector(context, state, l10n),
                            const SizedBox(height: 16),
                            _buildHostField(context, l10n),
                            const SizedBox(height: 16),
                            _buildPortField(context, l10n),
                            const SizedBox(height: 16),
                            _buildPathField(context, l10n),
                            const SizedBox(height: 24),
                            _buildPreview(state, l10n),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProtocolSelector(
      BuildContext context, AddApiState state, AppLocalizations l10n) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment<String>(value: 'http', label: Text(l10n.http)),
        ButtonSegment<String>(value: 'https', label: Text(l10n.https)),
      ],
      selected: {state.protocol},
      onSelectionChanged: (Set<String> newSelection) {
        context.read<AddApiBloc>().add(
              ProtocolChanged(newSelection.first),
            );
      },
    );
  }

  Widget _buildHostField(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _hostController,
      decoration: InputDecoration(
        labelText: l10n.host,
        hintText: 'example.com',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.dns),
      ),
      onChanged: (value) => context.read<AddApiBloc>().add(
            HostChanged(value),
          ),
    );
  }

  Widget _buildPortField(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _portController,
      decoration: InputDecoration(
        labelText: l10n.port,
        hintText: '5000',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.numbers),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) => context.read<AddApiBloc>().add(
            PortChanged(int.tryParse(value) ?? 0),
          ),
    );
  }

  Widget _buildPathField(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _urlPathController,
      decoration: InputDecoration(
        labelText: l10n.apiPath,
        hintText: 'api/v1',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.link),
      ),
      onChanged: (value) => context.read<AddApiBloc>().add(
            PathChanged(value),
          ),
    );
  }

  Widget _buildPreview(AddApiState state, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.preview}:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.fullUrl,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
