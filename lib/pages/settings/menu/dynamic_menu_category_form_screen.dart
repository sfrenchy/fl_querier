import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/menu_category.dart';
import 'package:querier/widgets/icon_selector.dart';
import 'package:querier/pages/settings/roles/bloc/roles_bloc.dart';
import 'package:querier/widgets/translation_manager.dart';

class MenuCategoryFormScreen extends StatefulWidget {
  final MenuCategory? categoryToEdit;

  const MenuCategoryFormScreen({super.key, this.categoryToEdit});

  @override
  State<MenuCategoryFormScreen> createState() => _MenuCategoryFormScreenState();
}

class _MenuCategoryFormScreenState extends State<MenuCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> _translations = {};
  final _iconController = TextEditingController();
  final _orderController = TextEditingController();
  final _routeController = TextEditingController();
  bool _isVisible = true;
  final List<String> _selectedRoles = ['User'];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    context.read<RolesBloc>().add(LoadRoles());
    if (widget.categoryToEdit != null) {
      _iconController.text = widget.categoryToEdit!.icon;
      _orderController.text = widget.categoryToEdit!.order.toString();
      _routeController.text = widget.categoryToEdit!.route;
      _isVisible = widget.categoryToEdit!.isVisible;
      _selectedRoles.clear();
      _selectedRoles.addAll(widget.categoryToEdit!.roles);

      _translations = widget.categoryToEdit!.names.map(
        (key, value) => MapEntry(key, TextEditingController(text: value)),
      );
    } else {
      _translations = {
        'en': TextEditingController(),
        'fr': TextEditingController(),
      };
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _orderController.dispose();
    _routeController.dispose();
    for (var controller in _translations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      setState(
          () => _error = AppLocalizations.of(context)!.atLeastOneRoleRequired);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final names = _translations
          .map((key, controller) => MapEntry(key, controller.text));

      final data = {
        'id': widget.categoryToEdit?.Id ?? 0,
        'names': names,
        'icon': _iconController.text,
        'order': int.parse(_orderController.text),
        'isVisible': _isVisible,
        'roles': _selectedRoles,
        'route': _routeController.text,
      };

      if (widget.categoryToEdit != null) {
        await context.read<ApiClient>().updateMenuCategory(
              widget.categoryToEdit!.Id,
              MenuCategory.fromJson(data),
            );
      } else {
        await context.read<ApiClient>().createMenuCategory(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryToEdit != null
            ? l10n.editMenuCategory
            : l10n.addMenuCategory),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslationManager(
                      translations: _translations.map((key, controller) => 
                        MapEntry(key, controller.text)
                      ),
                      onTranslationsChanged: (newValues) {
                        setState(() {
                          _translations.clear();
                          newValues.forEach((key, value) {
                            _translations[key] = TextEditingController(text: value);
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _iconController,
                    decoration: InputDecoration(
                      labelText: l10n.icon,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.iconRequired;
                      }
                      return null;
                    },
                  ),
                ),
                IconSelector(
                  icon: _iconController.text,
                  onIconSelected: (icon) => _iconController.text = icon,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orderController,
              decoration: InputDecoration(
                labelText: l10n.order,
                border: const OutlineInputBorder(),
              ),
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
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _routeController,
              decoration: InputDecoration(
                labelText: l10n.categoryRoute,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.routeRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.visibility),
              value: _isVisible,
              onChanged: (value) => setState(() => _isVisible = value),
            ),
            const SizedBox(height: 32),
            BlocBuilder<RolesBloc, RolesState>(
              builder: (context, state) {
                if (state is RolesLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.roles,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: state.roles.map((role) {
                          return FilterChip(
                            label: Text(role.name),
                            selected: _selectedRoles.contains(role.name),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedRoles.add(role.name);
                                } else {
                                  _selectedRoles.remove(role.name);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedRoles.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l10n.atLeastOneRoleRequired,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCategory,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
