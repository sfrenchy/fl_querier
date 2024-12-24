import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'smtp_configuration_screen.dart';
import 'admin_configuration_bloc.dart';
import 'package:querier/utils/validators.dart';

class AdminConfigurationScreen extends StatefulWidget {
  final String apiUrl;

  const AdminConfigurationScreen({
    super.key,
    required this.apiUrl,
  });

  @override
  State<AdminConfigurationScreen> createState() =>
      _AdminConfigurationScreenState();
}

class _AdminConfigurationScreenState extends State<AdminConfigurationScreen> {
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers
    _nameController.addListener(_validateForm);
    _firstNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty &&
          Validators.isValidEmail(_emailController.text) &&
          Validators.isValidPassword(_passwordController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => AdminConfigurationBloc(),
      child: BlocConsumer<AdminConfigurationBloc, AdminConfigurationState>(
        listener: (context, state) {
          if (state is AdminConfigurationSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SMTPConfigurationScreen(
                  adminName: _nameController.text,
                  adminFirstName: _firstNameController.text,
                  adminEmail: _emailController.text,
                  adminPassword: _passwordController.text,
                  apiUrl: widget.apiUrl,
                ),
              ),
            );
          } else if (state is AdminConfigurationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.configureSuperAdmin),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: l10n.firstName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      border: const OutlineInputBorder(),
                      errorText: _emailController.text.isNotEmpty &&
                              !Validators.isValidEmail(_emailController.text)
                          ? l10n.validEmail
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      border: const OutlineInputBorder(),
                      helperText: l10n.passwordRequirements,
                      errorText: _passwordController.text.isNotEmpty
                          ? Validators.getPasswordError(
                              _passwordController.text)
                          : null,
                    ),
                    validator: (value) =>
                        Validators.getPasswordError(value ?? ''),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (state is! AdminConfigurationLoading && _isFormValid)
                              ? () {
                                  context.read<AdminConfigurationBloc>().add(
                                        SubmitConfigurationEvent(
                                          name: _nameController.text,
                                          firstName: _firstNameController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        ),
                                      );
                                }
                              : null,
                      child: state is AdminConfigurationLoading
                          ? const CircularProgressIndicator()
                          : Text(l10n.next),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
