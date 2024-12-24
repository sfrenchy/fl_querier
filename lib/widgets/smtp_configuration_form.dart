import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SmtpConfigurationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback? onTest;
  final bool showTestButton;
  final String? initialHost;
  final int? initialPort;
  final String? initialUsername;
  final String? initialPassword;
  final bool? initialUseSSL;
  final String? initialSenderEmail;
  final String? initialSenderName;
  final bool? initialRequireAuth;
  final void Function(
      String host,
      int port,
      String username,
      String password,
      bool useSSL,
      String senderEmail,
      String senderName,
      bool requireAuth)? onSaveValues;

  const SmtpConfigurationForm({
    super.key,
    required this.formKey,
    this.onTest,
    this.showTestButton = false,
    this.initialHost,
    this.initialPort,
    this.initialUsername,
    this.initialPassword,
    this.initialUseSSL,
    this.initialSenderEmail,
    this.initialSenderName,
    this.initialRequireAuth,
    this.onSaveValues,
  });

  @override
  State<SmtpConfigurationForm> createState() => _SmtpConfigurationFormState();
}

class _SmtpConfigurationFormState extends State<SmtpConfigurationForm> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _senderEmailController = TextEditingController();
  final _senderNameController = TextEditingController();
  bool _useSSL = true;
  bool _useAuth = true;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _hostController.text = widget.initialHost ?? '';
    _portController.text = (widget.initialPort ?? 587).toString();
    _usernameController.text = widget.initialUsername ?? '';
    _passwordController.text = widget.initialPassword ?? '';
    _useSSL = widget.initialUseSSL ?? true;
    _senderEmailController.text = widget.initialSenderEmail ?? '';
    _senderNameController.text = widget.initialSenderName ?? '';
    _useAuth = widget.initialRequireAuth ?? true;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _senderEmailController.dispose();
    _senderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _hostController,
            decoration: InputDecoration(
              labelText: l10n.smtpHost,
              border: const OutlineInputBorder(),
            ),
            onSaved: (value) {
              if (value != null && widget.onSaveValues != null) {
                widget.onSaveValues!(
                  value,
                  int.tryParse(_portController.text) ?? 587,
                  _usernameController.text,
                  _passwordController.text,
                  _useSSL,
                  _senderEmailController.text,
                  _senderNameController.text,
                  _useAuth,
                );
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _portController,
            decoration: InputDecoration(
              labelText: l10n.smtpPort,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired;
              }
              final port = int.tryParse(value);
              if (port == null || port <= 0 || port > 65535) {
                return l10n.invalidPort;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.useAuthentication),
            value: _useAuth,
            onChanged: (bool value) {
              setState(() {
                _useAuth = value;
              });
            },
          ),
          if (_useAuth) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.smtpUsername,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.smtpPassword,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _senderEmailController,
            decoration: InputDecoration(
              labelText: l10n.smtpSenderEmail,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _senderNameController,
            decoration: InputDecoration(
              labelText: l10n.smtpSenderName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.useSSL),
            value: _useSSL,
            onChanged: (bool value) {
              setState(() {
                _useSSL = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.showTestButton) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onTest,
                    child: Text(l10n.testConnection),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
