import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/blocs/language_bloc.dart';
import 'package:querier/pages/add_api/add_api_screen.dart';
import 'package:querier/pages/configure_api/admin_configuration_screen.dart';
import 'package:querier/pages/home/home_screen.dart';
import 'login_bloc.dart';
import 'package:querier/widgets/loading_screen.dart';
import 'package:querier/widgets/controller_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Querier'),
        actions: [
          _buildLanguageSelector(context),
        ],
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          if (state.isAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FutureBuilder(
                  future: Future.delayed(const Duration(seconds: 2)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      });
                    }
                    return const LoadingScreen();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Center(
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
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: Image.asset(
                              'assets/images/querier_logo_no_bg_big.png',
                              width: 200,
                            ),
                          ),
                          _buildApiUrlDropdown(context, state),
                          const SizedBox(height: 24),
                          if (state.selectedUrl.isNotEmpty) ...[
                            if (state.isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: CircularProgressIndicator(),
                              )
                            else if (state.isConfigured) ...[
                              _buildEmailField(context),
                              const SizedBox(height: 16),
                              _buildPasswordField(context),
                              const SizedBox(height: 32),
                              _buildLoginButton(context, state),
                            ] else ...[
                              const SizedBox(height: 24),
                              _buildConfigureButton(context),
                            ],
                          ],
                        ],
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

  Widget _buildApiUrlDropdown(BuildContext context, LoginState state) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: state.selectedUrl.isEmpty ? null : state.selectedUrl,
                hint: Text(l10n.selectApiUrl),
                items: state.urls.map((url) {
                  return DropdownMenuItem(
                    value: url,
                    child: Text(url),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    context.read<LoginBloc>().add(UrlChanged(newValue));
                  }
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddApiScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: l10n.email,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: l10n.password,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      obscureText: !_showPassword,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () {
                context.read<LoginBloc>().add(
                      LoginSubmitted(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                    );
              },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: state.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(l10n.login),
      ),
    );
  }

  Widget _buildConfigureButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminConfigurationScreen(
                apiUrl: context.read<LoginBloc>().state.selectedUrl,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(l10n.configureApi),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (Locale locale) {
        context.read<LanguageBloc>().changeLanguage(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: const [
              Text('🇬🇧 '),
              SizedBox(width: 8),
              Text('English'),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('fr'),
          child: Row(
            children: const [
              Text('🇫🇷 '),
              SizedBox(width: 8),
              Text('Français'),
            ],
          ),
        ),
      ],
    );
  }
}
