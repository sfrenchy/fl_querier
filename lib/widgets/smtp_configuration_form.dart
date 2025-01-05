import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/utils/validators.dart';

class SmtpConfigurationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String? initialHost;
  final int? initialPort;
  final String? initialUsername;
  final String? initialPassword;
  final bool? initialUseSSL;
  final String? initialSenderEmail;
  final String? initialSenderName;
  final bool? initialRequireAuth;
  final bool? testSuccess;
  final String? testError;
  final Function(
      String host,
      int port,
      String username,
      String password,
      bool useSSL,
      String senderEmail,
      String senderName,
      bool requireAuth) onSaveValues;

  const SmtpConfigurationForm({
    super.key,
    required this.formKey,
    this.initialHost,
    this.initialPort,
    this.initialUsername,
    this.initialPassword,
    this.initialUseSSL,
    this.initialSenderEmail,
    this.initialSenderName,
    this.initialRequireAuth,
    this.testSuccess,
    this.testError,
    required this.onSaveValues,
  });

  @override
  State<SmtpConfigurationForm> createState() => SmtpConfigurationFormState();
}

class SmtpConfigurationFormState extends State<SmtpConfigurationForm> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '587');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _senderEmailController = TextEditingController();
  final _senderNameController = TextEditingController();
  bool _useSSL = true;
  bool _useAuth = true;
  bool _showPassword = false;

  void getValues(
      Function(
              String host,
              int port,
              String username,
              String password,
              bool useSSL,
              String senderEmail,
              String senderName,
              bool requireAuth)
          callback) {
    callback(
      _hostController.text,
      int.parse(_portController.text),
      _usernameController.text,
      _passwordController.text,
      _useSSL,
      _senderEmailController.text,
      _senderNameController.text,
      _useAuth,
    );
  }

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
          if (widget.testSuccess != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.testSuccess == true
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.testSuccess == true ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.testSuccess == true
                        ? Icons.check_circle
                        : Icons.error,
                    color:
                        widget.testSuccess == true ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.testSuccess == true
                          ? l10n.connectionSuccess
                          : widget.testError ?? l10n.connectionFailed,
                      style: TextStyle(
                        color: widget.testSuccess == true
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _hostController,
            decoration: InputDecoration(
              labelText: l10n.smtpHost,
              border: const OutlineInputBorder(),
            ),
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
              validator: (value) {
                if (_useAuth && (value == null || value.isEmpty)) {
                  return l10n.fieldRequired;
                }
                return null;
              },
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
              validator: (value) {
                if (_useAuth && (value == null || value.isEmpty)) {
                  return l10n.fieldRequired;
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _senderEmailController,
            decoration: InputDecoration(
              labelText: l10n.smtpSenderEmail,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired;
              }
              if (!Validators.isValidEmail(value)) {
                return l10n.invalidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _senderNameController,
            decoration: InputDecoration(
              labelText: l10n.smtpSenderName,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
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
        ],
      ),
    );
  }
}
