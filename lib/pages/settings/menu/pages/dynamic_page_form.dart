import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/page.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_bloc.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_event.dart';
import 'package:querier/widgets/icon_selector.dart';
import 'package:querier/widgets/translation_manager.dart';

class MenuPageForm extends StatefulWidget {
  final MenuPage? page;
  final int menuCategoryId;
  final VoidCallback onSaved;
  final ApiClient apiClient;
  final DynamicPagesBloc pagesBloc;

  const MenuPageForm({
    super.key,
    this.page,
    required this.menuCategoryId,
    required this.onSaved,
    required this.apiClient,
    required this.pagesBloc,
  });

  @override
  State<MenuPageForm> createState() => _MenuPageFormState();
}

class _MenuPageFormState extends State<MenuPageForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _translations = {
    'en': TextEditingController()
  };
  String _icon = 'dashboard';
  int _order = 1;
  bool _isVisible = true;
  String _route = '';
  Map<String, String> _names = {};
  List<String> _roles = ['User'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.page != null) {
      _translations.clear();
      widget.page!.names.forEach((key, value) {
        _translations[key] = TextEditingController(text: value);
      });
      _icon = widget.page!.icon;
      _order = widget.page!.order;
      _isVisible = widget.page!.isVisible;
      _route = widget.page!.route;
      _names = widget.page!.names;
      _roles = widget.page!.roles;
    }
  }

  @override
  void dispose() {
    for (var controller in _translations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.page == null ? l10n.addPage : l10n.editPage),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submitForm,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslationManager(
                translations: _translations
                    .map((key, controller) => MapEntry(key, controller.text)),
                onTranslationsChanged: (newTranslations) {
                  setState(() {
                    _translations.clear();
                    newTranslations.forEach((key, value) {
                      _translations[key] = TextEditingController(text: value);
                    });
                    _names = newTranslations;
                  });
                },
              ),
              const SizedBox(height: 16),
              IconSelector(
                icon: _icon,
                onIconSelected: (icon) => setState(() => _icon = icon),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _order.toString(),
                decoration: InputDecoration(labelText: l10n.order),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.orderRequired;
                  }
                  if (int.tryParse(value) == null) {
                    return l10n.invalidOrder;
                  }
                  return null;
                },
                onSaved: (value) => _order = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _route,
                decoration: InputDecoration(labelText: l10n.route),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.routeRequired;
                  }
                  return null;
                },
                onSaved: (value) => _route = value!,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.visibility),
                value: _isVisible,
                onChanged: (value) => setState(() => _isVisible = value),
              ),
              // TODO: Ajouter un sélecteur de rôles
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        _names = _translations.map(
          (key, controller) => MapEntry(key, controller.text),
        );

        final page = MenuPage(
          id: widget.page?.id ?? 0,
          names: _names,
          icon: _icon,
          order: _order,
          isVisible: _isVisible,
          roles: _roles,
          route: _route,
          menuCategoryId: widget.menuCategoryId,
        );

        if (widget.page == null) {
          await widget.apiClient.createPage(page);
        } else {
          await widget.apiClient.updatePage(page.id, page);
        }

        if (mounted) {
          widget.pagesBloc.add(LoadPages(widget.menuCategoryId));
          widget.onSaved();
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
