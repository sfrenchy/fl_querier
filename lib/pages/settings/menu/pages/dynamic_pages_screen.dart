import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/blocs/menu_bloc.dart';
import 'package:querier/models/menu_category.dart';
import 'package:querier/models/page.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_bloc.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_event.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_pages_state.dart';
import 'package:querier/pages/settings/menu/pages/dynamic_page_form.dart';
import 'package:querier/pages/settings/menu/pages/dynamic_page_layout_screen.dart';
import 'package:querier/widgets/icon_selector.dart';

class DynamicPagesScreen extends StatelessWidget {
  final MenuCategory category;

  const DynamicPagesScreen({super.key, required this.category});

  Future<void> _confirmDelete(BuildContext context, MenuPage page) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeletePageMessage),
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

    if (confirmed == true && context.mounted) {
      context.read<DynamicPagesBloc>().add(DeletePage(page.id));
      context.read<MenuBloc>().add(LoadMenu());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pages),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPageForm(context),
          ),
        ],
      ),
      body: BlocBuilder<DynamicPagesBloc, DynamicPagesState>(
        builder: (context, state) {
          if (state is DynamicPagesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicPagesError) {
            return Center(child: Text(state.message));
          }

          if (state is DynamicPagesLoaded) {
            if (state.pages.isEmpty) {
              return Center(child: Text(l10n.noPagesYet));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(50), // Checkbox
                    1: FlexColumnWidth(3), // Name
                    2: FlexColumnWidth(1), // Icon
                    3: FlexColumnWidth(1), // Order
                    4: FlexColumnWidth(1), // Visibility
                    5: FlexColumnWidth(2), // Roles
                    6: FlexColumnWidth(2), // Actions
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      children: [
                        const TableCell(child: SizedBox(width: 50)),
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(l10n.name,
                              style: Theme.of(context).textTheme.titleSmall),
                        )),
                        TableCell(
                            child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(l10n.icon,
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        )),
                        TableCell(
                            child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(l10n.order,
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        )),
                        TableCell(
                            child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(l10n.visibility,
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        )),
                        TableCell(
                            child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(l10n.roles,
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        )),
                        TableCell(
                            child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(l10n.actions,
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        )),
                      ],
                    ),
                    ...state.pages.map((page) => TableRow(
                          children: [
                            TableCell(
                                child: Center(
                              child: Checkbox(
                                value: false,
                                onChanged: (value) {},
                              ),
                            )),
                            TableCell(
                                child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(page.getLocalizedName(
                                Localizations.localeOf(context).languageCode,
                              )),
                            )),
                            TableCell(
                                child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(IconSelector(
                                  icon: page.icon,
                                  onIconSelected: (_) {},
                                ).getIconData(page.icon)),
                              ),
                            )),
                            TableCell(
                                child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(page.order.toString()),
                              ),
                            )),
                            TableCell(
                                child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Switch(
                                  value: page.isVisible,
                                  onChanged: (value) {
                                    context.read<DynamicPagesBloc>().add(
                                          UpdatePageVisibility(page, value),
                                        );
                                  },
                                ),
                              ),
                            )),
                            TableCell(
                                child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(page.roles.join(', ')),
                              ),
                            )),
                            TableCell(
                                child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.dashboard),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DynamicPageLayoutScreen(
                                            pageId: page.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showPageForm(context, page: page),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _confirmDelete(context, page),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        )),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showPageForm(BuildContext context, {MenuPage? page}) {
    final bloc = context.read<DynamicPagesBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: MenuPageForm(
            apiClient: context.read<ApiClient>(),
            menuCategoryId: category.Id,
            page: page,
            pagesBloc: bloc,
            onSaved: () {
              bloc.add(LoadPages(category.Id));
              context.read<MenuBloc>().add(LoadMenu());
            },
          ),
        ),
      ),
    );
  }
}
