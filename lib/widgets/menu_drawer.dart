import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/blocs/menu_bloc.dart';
import 'package:querier/models/menu_category.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is MenuLoading) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is MenuError) {
          return Drawer(
            child: Center(child: Text(state.message)),
          );
        }

        if (state is MenuLoaded) {
          final categories = state.categories;

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/querier_logo_no_bg_big.png',
                      height: 80,
                    ),
                  ),
                ),
                ...categories.map((category) {
                  if (!category.isVisible) {
                    return const SizedBox.shrink();
                  }

                  final pages =
                      category.pages.where((page) => page.isVisible).toList();

                  return ExpansionTile(
                    leading: Icon(category.getIconData()),
                    title: Text(category.getLocalizedName(locale.languageCode)),
                    initiallyExpanded: true,
                    children: pages
                        .map((page) => ListTile(
                              leading: Icon(page.getIconData()),
                              title: Text(
                                  page.getLocalizedName(locale.languageCode)),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/dynamic-page',
                                  arguments: page.id,
                                );
                              },
                            ))
                        .toList(),
                  );
                }).toList(),
              ],
            ),
          );
        }

        return const Drawer();
      },
    );
  }
}
