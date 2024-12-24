import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/models/menu_category.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_bloc.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_event.dart';
import 'bloc/dynamic_menu_categories_bloc.dart';
import 'pages/dynamic_pages_screen.dart';

class DynamicMenuCategoriesScreen extends StatelessWidget {
  const DynamicMenuCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DynamicMenuCategoriesBloc(
        context.read<ApiClient>(),
        context,
      )..add(LoadDynamicMenuCategories()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.menuCategories),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.pushNamed(context, '/menu/form'),
              ),
            ],
          ),
          body: BlocBuilder<DynamicMenuCategoriesBloc,
              DynamicMenuCategoriesState>(
            builder: (context, state) {
              if (state is DynamicMenuCategoriesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DynamicMenuCategoriesError) {
                return Center(child: Text(state.message));
              }

              if (state is DynamicMenuCategoriesLoaded) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 32,
                        ),
                        child: DataTable(
                          columnSpacing: 24.0,
                          horizontalMargin: 24.0,
                          columns: [
                            DataColumn(
                              label: Expanded(
                                child: Text(AppLocalizations.of(context)!.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(AppLocalizations.of(context)!.icon,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(AppLocalizations.of(context)!.order,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                    AppLocalizations.of(context)!.visibility,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(AppLocalizations.of(context)!.roles,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                    AppLocalizations.of(context)!.actions,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                          rows: state.categories.map((category) {
                            return DataRow(
                              cells: [
                                DataCell(Text(category.getLocalizedName(
                                    Localizations.localeOf(context)
                                        .languageCode))),
                                DataCell(Icon(category.getIconData())),
                                DataCell(Text(category.order.toString())),
                                DataCell(
                                  Switch(
                                    value: category.isVisible,
                                    onChanged: (value) {
                                      context
                                          .read<DynamicMenuCategoriesBloc>()
                                          .add(
                                            UpdateDynamicMenuCategoryVisibility(
                                                category, value),
                                          );
                                    },
                                  ),
                                ),
                                DataCell(Text(category.roles.join(', '))),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.menu_book),
                                        tooltip:
                                            AppLocalizations.of(context)!.pages,
                                        onPressed: () {
                                          _showPages(context, category);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        tooltip:
                                            AppLocalizations.of(context)!.edit,
                                        onPressed: () async {
                                          final result =
                                              await Navigator.pushNamed(
                                            context,
                                            '/menu/form',
                                            arguments: category,
                                          );
                                          if (result == true &&
                                              context.mounted) {
                                            context
                                                .read<
                                                    DynamicMenuCategoriesBloc>()
                                                .add(
                                                    LoadDynamicMenuCategories());
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        tooltip: AppLocalizations.of(context)!
                                            .delete,
                                        onPressed: () =>
                                            _confirmDelete(context, category),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelectChanged: (_) async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/menu/form',
                                  arguments: category,
                                );
                                if (result == true && context.mounted) {
                                  context
                                      .read<DynamicMenuCategoriesBloc>()
                                      .add(LoadDynamicMenuCategories());
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, MenuCategory category) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMenuCategory),
        content: Text(
            '${l10n.confirmDelete} ${category.getLocalizedName(Localizations.localeOf(context).languageCode)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        context
            .read<DynamicMenuCategoriesBloc>()
            .add(DeleteDynamicMenuCategory(category.Id));
      }
    }
  }

  void _showPages(BuildContext context, MenuCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => DynamicPagesBloc(
            context.read<ApiClient>(),
          )..add(LoadPages(category.Id)),
          child: DynamicPagesScreen(category: category),
        ),
      ),
    );
  }
}
