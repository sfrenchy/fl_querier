import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'smtp_configuration_bloc.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/widgets/smtp_configuration_form.dart';

class SMTPConfigurationScreen extends StatefulWidget {
  final String adminName;
  final String adminFirstName;
  final String adminEmail;
  final String adminPassword;
  final String apiUrl;

  const SMTPConfigurationScreen({
    super.key,
    required this.adminName,
    required this.adminFirstName,
    required this.adminEmail,
    required this.adminPassword,
    required this.apiUrl,
  });

  @override
  State<SMTPConfigurationScreen> createState() =>
      _SMTPConfigurationScreenState();
}

class _SMTPConfigurationScreenState extends State<SMTPConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) =>
          SmtpConfigurationBloc(widget.apiUrl, Navigator.of(context)),
      child: BlocConsumer<SmtpConfigurationBloc, SmtpConfigurationState>(
        listener: (context, state) async {
          if (state is SmtpConfigurationSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is SmtpConfigurationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is SmtpTestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.connectionSuccess)),
            );
          } else if (state is SmtpTestFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.connectionFailed)),
            );
          } else if (state is SmtpConfigurationSuccessWithAuth) {
            final token = state.authResponse['Token'];
            final refreshToken = state.authResponse['RefreshToken'];

            context.read<ApiClient>().setAuthToken(token);
            await context.read<ApiClient>().storeRefreshToken(refreshToken);

            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.smtpConfiguration),
              actions: [
                IconButton(
                  tooltip: l10n.save,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                    }
                  },
                  icon: const Icon(Icons.save),
                ),
                IconButton(
                  tooltip: l10n.testConnection,
                  onPressed: () {
                    context
                        .read<SmtpConfigurationBloc>()
                        .add(TestSmtpConfigurationEvent(
                          host: '', // TODO: Get values from form
                          port: 0,
                          username: '',
                          password: '',
                          senderEmail: '',
                          senderName: '',
                          useSsl: true,
                        ));
                  },
                  icon: const Icon(Icons.send_outlined),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SmtpConfigurationForm(
                          formKey: _formKey,
                          onSaveValues: (host, port, username, password, useSSL,
                              senderEmail, senderName, requireAuth) {
                            context.read<SmtpConfigurationBloc>().add(
                                  SubmitSmtpConfigurationEvent(
                                    adminName: widget.adminName,
                                    adminFirstName: widget.adminFirstName,
                                    adminEmail: widget.adminEmail,
                                    adminPassword: widget.adminPassword,
                                    apiUrl: widget.apiUrl,
                                    host: host,
                                    port: port,
                                    username: username,
                                    password: password,
                                    useSSL: useSSL,
                                    senderEmail: senderEmail,
                                    senderName: senderName,
                                    requireAuth: requireAuth,
                                  ),
                                );
                          },
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
}
