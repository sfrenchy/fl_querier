import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/api_configuration.dart';
import 'package:querier/widgets/smtp_configuration_form.dart';

class SettingServicesScreen extends StatefulWidget {
  const SettingServicesScreen({super.key});

  @override
  State<SettingServicesScreen> createState() => _SettingServicesScreenState();
}

class _SettingServicesScreenState extends State<SettingServicesScreen> {
  late final l10n = AppLocalizations.of(context)!;
  final _formKey = GlobalKey<FormState>();
  final _apiFormKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs SMTP
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _senderEmailController = TextEditingController();
  final _senderNameController = TextEditingController();
  bool _useSSL = true;
  bool _useAuth = true;
  bool _requireDigit = false;
  bool _requireLowercase = false;
  bool _requireUppercase = false;
  bool _requireNonAlphanumeric = false;
  bool _allowAllCrossOrigins = false;
  final _resetPasswordTokenValidityController = TextEditingController();
  final _emailConfirmationTokenValidityController = TextEditingController();
  final _requiredLengthController = TextEditingController();

  // Ajouter ces contrôleurs avec les autres
  final _allowedHostsController = TextEditingController();
  final _allowedOriginsController = TextEditingController();
  final _allowedHeadersController = TextEditingController();
  final _allowedMethodsController = TextEditingController();

  // Contrôleurs pour Redis
  final _redisHostController = TextEditingController();
  final _redisPortController = TextEditingController();
  bool _redisEnabled = false;

  // Ajouter cette variable pour gérer l'état d'expansion
  List<bool> _isExpanded = [false, false, false];

  // Ajouter ces contrôleurs avec les autres
  final _apiHostController = TextEditingController();
  final _apiPortController = TextEditingController();
  String _selectedProtocol = 'https';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApiConfiguration();
  }

  Future<void> _loadApiConfiguration() async {
    try {
      final config = await context.read<ApiClient>().getApiConfiguration();
      setState(() {
        _selectedProtocol = config.scheme;
        _apiHostController.text = config.host;
        _apiPortController.text = config.port.toString();
        _allowedHostsController.text = config.allowedHosts;
        _allowedOriginsController.text = config.allowedOrigins;
        _allowedMethodsController.text = config.allowedMethods;
        _allowedHeadersController.text = config.allowedHeaders;
        _resetPasswordTokenValidityController.text =
            config.resetPasswordTokenValidity.toString();
        _emailConfirmationTokenValidityController.text =
            config.emailConfirmationTokenValidity.toString();
        _requireDigit = config.requireDigit;
        _requireLowercase = config.requireLowercase;
        _requireNonAlphanumeric = config.requireNonAlphanumeric;
        _requireUppercase = config.requireUppercase;
        _requiredLengthController.text = config.requiredLength.toString();
        _hostController.text = config.smtpHost;
        _portController.text = config.smtpPort.toString();
        _usernameController.text = config.smtpUsername;
        _passwordController.text = config.smtpPassword;
        _senderEmailController.text = config.smtpSenderEmail;
        _senderNameController.text = config.smtpSenderName;
        _useSSL = config.smtpUseSSL;
        _useAuth = config.smtpRequireAuth;
        _redisEnabled = config.redisEnabled;
        _redisHostController.text = config.redisHost;
        _redisPortController.text = config.redisPort.toString();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingConfiguration)),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _senderEmailController.dispose();
    _senderNameController.dispose();
    _resetPasswordTokenValidityController.dispose();
    _emailConfirmationTokenValidityController.dispose();
    _requiredLengthController.dispose();
    _allowedHostsController.dispose();
    _allowedOriginsController.dispose();
    _allowedHeadersController.dispose();
    _allowedMethodsController.dispose();
    _redisHostController.dispose();
    _redisPortController.dispose();
    _apiHostController.dispose();
    _apiPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.services),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              bool isValid = true;

              // Valider le formulaire API si il est initialisé
              if (_apiFormKey.currentState != null) {
                isValid = isValid && _apiFormKey.currentState!.validate();
              }

              // Valider le formulaire SMTP si il est initialisé
              if (_formKey.currentState != null) {
                isValid = isValid && _formKey.currentState!.validate();
                if (isValid) {
                  _formKey.currentState!.save();
                }
              }

              if (isValid) {
                try {
                  final config = ApiConfiguration(
                    scheme: _selectedProtocol,
                    host: _apiHostController.text,
                    port: int.parse(_apiPortController.text),
                    allowedHosts: _allowedHostsController.text,
                    allowedOrigins: _allowedOriginsController.text,
                    allowedMethods: _allowedMethodsController.text,
                    allowedHeaders: _allowedHeadersController.text,
                    resetPasswordTokenValidity:
                        int.parse(_resetPasswordTokenValidityController.text),
                    emailConfirmationTokenValidity: int.parse(
                        _emailConfirmationTokenValidityController.text),
                    requireDigit: _requireDigit,
                    requireLowercase: _requireLowercase,
                    requireNonAlphanumeric: _requireNonAlphanumeric,
                    requireUppercase: _requireUppercase,
                    requiredLength: int.parse(_requiredLengthController.text),
                    requiredUniqueChars: 1,
                    smtpHost: _hostController.text,
                    smtpPort: int.parse(_portController.text),
                    smtpUsername: _usernameController.text,
                    smtpPassword: _passwordController.text,
                    smtpUseSSL: _useSSL,
                    smtpSenderEmail: _senderEmailController.text,
                    smtpSenderName: _senderNameController.text,
                    smtpRequireAuth: _useAuth,
                    redisEnabled: _redisEnabled,
                    redisHost: _redisHostController.text,
                    redisPort: int.parse(_redisPortController.text),
                  );

                  final success = await context
                      .read<ApiClient>()
                      .updateApiConfiguration(config);

                  if (success && mounted) {
                    await _loadApiConfiguration();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.configurationSaved)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorSavingConfiguration)),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpansionPanelList(
            elevation: 1,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _isExpanded[index] = !_isExpanded[index];
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    leading: const Icon(Icons.api),
                    title: Text(l10n.apiConfiguration),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _apiFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'http',
                              label: Text('HTTP'),
                            ),
                            ButtonSegment<String>(
                              value: 'https',
                              label: Text('HTTPS'),
                            ),
                          ],
                          selected: {_selectedProtocol},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedProtocol = newSelection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _apiHostController,
                          decoration: InputDecoration(
                            labelText: l10n.host,
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
                          controller: _apiPortController,
                          decoration: InputDecoration(
                            labelText: l10n.port,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
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
                        // Paramètres de sécurité
                        TextFormField(
                          controller: _resetPasswordTokenValidityController,
                          decoration: InputDecoration(
                            labelText: l10n.resetPasswordTokenValidity,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailConfirmationTokenValidityController,
                          decoration: InputDecoration(
                            labelText: l10n.emailConfirmationTokenValidity,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        // Règles de mot de passe
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.passwordRules,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                SwitchListTile(
                                  title: Text(l10n.requireDigit),
                                  value: _requireDigit,
                                  onChanged: (value) =>
                                      setState(() => _requireDigit = value),
                                ),
                                SwitchListTile(
                                  title: Text(l10n.requireLowercase),
                                  value: _requireLowercase,
                                  onChanged: (value) =>
                                      setState(() => _requireLowercase = value),
                                ),
                                SwitchListTile(
                                  title: Text(l10n.requireUppercase),
                                  value: _requireUppercase,
                                  onChanged: (value) =>
                                      setState(() => _requireUppercase = value),
                                ),
                                SwitchListTile(
                                  title: Text(l10n.requireNonAlphanumeric),
                                  value: _requireNonAlphanumeric,
                                  onChanged: (value) => setState(
                                      () => _requireNonAlphanumeric = value),
                                ),
                                TextFormField(
                                  controller: _requiredLengthController,
                                  decoration: InputDecoration(
                                    labelText: l10n.requiredLength,
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Configuration CORS
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.corsConfiguration,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _allowedHostsController,
                                  decoration: InputDecoration(
                                    labelText: l10n.allowedHosts,
                                    hintText: '*',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _allowedOriginsController,
                                  decoration: InputDecoration(
                                    labelText: l10n.allowedOrigins,
                                    hintText: 'https://example.com, *',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(l10n.allowedMethods,
                                    style:
                                        Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _allowedMethodsController,
                                  decoration: InputDecoration(
                                    labelText: l10n.allowedMethods,
                                    hintText: 'GET, POST, DELETE, OPTIONS',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _allowedHeadersController,
                                  decoration: InputDecoration(
                                    labelText: l10n.allowedHeaders,
                                    hintText:
                                        'X-Request-Token, Accept, Content-Type, Authorization',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                isExpanded: _isExpanded[0],
                canTapOnHeader: true,
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(l10n.smtpConfiguration),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SmtpConfigurationForm(
                    formKey: _formKey,
                    initialHost: _hostController.text,
                    initialPort: int.parse(_portController.text),
                    initialUsername: _usernameController.text,
                    initialPassword: _passwordController.text,
                    initialUseSSL: _useSSL,
                    initialSenderEmail: _senderEmailController.text,
                    initialSenderName: _senderNameController.text,
                    initialRequireAuth: _useAuth,
                    onSaveValues: (host, port, username, password, useSSL,
                        senderEmail, senderName, requireAuth) {
                      setState(() {
                        _hostController.text = host;
                        _portController.text = port.toString();
                        _usernameController.text = username;
                        _passwordController.text = password;
                        _useSSL = useSSL;
                        _senderEmailController.text = senderEmail;
                        _senderNameController.text = senderName;
                        _useAuth = requireAuth;
                      });
                    },
                  ),
                ),
                isExpanded: _isExpanded[1],
                canTapOnHeader: true,
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    leading: const Icon(Icons.storage),
                    title: Text(l10n.redisConfiguration),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: Text(l10n.enable),
                          value: _redisEnabled,
                          onChanged: (value) =>
                              setState(() => _redisEnabled = value),
                        ),
                        if (_redisEnabled) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _redisHostController,
                            decoration: InputDecoration(
                              labelText: l10n.redisHost,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _redisPortController,
                            decoration: InputDecoration(
                              labelText: l10n.redisPort,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                isExpanded: _isExpanded[2],
                canTapOnHeader: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
