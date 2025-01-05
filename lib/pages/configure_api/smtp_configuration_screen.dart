import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/blocs/menu_bloc.dart';
import 'package:querier/pages/configure_api/smtp_configuration_bloc.dart';
import 'package:querier/providers/auth_provider.dart';
import 'package:querier/widgets/smtp_configuration_form.dart';

class SmtpConfigurationScreen extends StatefulWidget {
  final String apiUrl;
  final String adminName;
  final String adminFirstName;
  final String adminEmail;
  final String adminPassword;

  const SmtpConfigurationScreen({
    super.key,
    required this.apiUrl,
    required this.adminName,
    required this.adminFirstName,
    required this.adminEmail,
    required this.adminPassword,
  });

  @override
  State<SmtpConfigurationScreen> createState() =>
      _SmtpConfigurationScreenState();
}

class _SmtpConfigurationScreenState extends State<SmtpConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formStateKey = GlobalKey<SmtpConfigurationFormState>();
  bool _isLoading = false;
  bool? _testSuccess;
  String? _testError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => SmtpConfigurationBloc(
        widget.apiUrl,
        Navigator.of(context),
      ),
      child: BlocConsumer<SmtpConfigurationBloc, SmtpConfigurationState>(
        listener: (context, state) {
          if (state is SmtpConfigurationLoading || state is SmtpTestLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });

            if (state is SmtpConfigurationSuccess) {
              Navigator.of(context).pushReplacementNamed('/home');
            } else if (state is SmtpConfigurationSuccessWithAuth) {
              final authProvider = context.read<AuthProvider>();
              authProvider.updateFromAuthResponse(state.authResponse);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  context.read<MenuBloc>().add(LoadMenu());
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              });
            } else if (state is SmtpConfigurationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state is SmtpTestSuccess) {
              setState(() {
                _testSuccess = true;
                _testError = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.connectionSuccess),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            } else if (state is SmtpTestFailure) {
              setState(() {
                _testSuccess = false;
                _testError = state.error;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.smtpConfiguration),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _testSuccess = null;
                              _testError = null;
                            });
                            _formStateKey.currentState?.getValues((host,
                                port,
                                username,
                                password,
                                useSSL,
                                senderEmail,
                                senderName,
                                requireAuth) {
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
                            });
                          }
                        },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    minHeight: 600,
                  ),
                  child: Center(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SmtpConfigurationForm(
                          key: _formStateKey,
                          formKey: _formKey,
                          testSuccess: _testSuccess,
                          testError: _testError,
                          onSaveValues: (_, __, ___, ____, _____, ______,
                              _______, ________) {},
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
