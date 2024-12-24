import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:querier/const.dart';
import 'package:querier/models/db_connection.dart';
import 'package:querier/models/menu_category.dart';
import 'package:querier/models/role.dart';
import 'package:querier/models/sql_query.dart';
import 'package:querier/models/user.dart';
import 'package:querier/pages/home/home_screen.dart';
import 'package:querier/pages/login/login_bloc.dart';
import 'package:querier/pages/login/login_screen.dart';
import 'package:querier/pages/add_api/add_api_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/blocs/language_bloc.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/config.dart';
import 'package:querier/pages/queries/bloc/queries_bloc.dart';
import 'package:querier/pages/queries/queries_screen.dart';
import 'package:querier/pages/settings/menu/bloc/dynamic_menu_categories_bloc.dart';
import 'package:querier/pages/settings/roles/bloc/roles_bloc.dart';
import 'package:querier/pages/settings/users/bloc/users_bloc.dart';
import 'package:querier/pages/settings/users/setting_users_screen.dart';
import 'package:querier/pages/settings/roles/setting_roles_screen.dart';
import 'package:querier/pages/settings/services/setting_services_screen.dart';
import 'package:querier/pages/settings/users/user_form_screen.dart';
import 'package:querier/pages/settings/roles/role_form_screen.dart';
import 'package:querier/theme/theme.dart';
import 'package:querier/providers/auth_provider.dart';
import 'package:querier/pages/profile/profile_screen.dart';
import 'package:querier/pages/databases/databases_screen.dart';
import 'package:querier/pages/databases/database_form_screen.dart';
import 'package:querier/pages/databases/database_details_screen.dart';
import 'package:querier/pages/settings/menu/dynamic_menu_categories_screen.dart';
import 'package:querier/pages/settings/menu/dynamic_menu_category_form_screen.dart';
import 'package:querier/blocs/menu_bloc.dart';
import 'package:querier/widgets/query_builder/sql_query_builder_screen.dart';
import 'package:querier/pages/queries/sql_query_form_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const QuerierApp());
}

class QuerierApp extends StatelessWidget {
  const QuerierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (context) =>
              ApiClient(Config.apiBaseUrl, navigatorKey.currentState!),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<ApiClient>()),
        ),
        BlocProvider<MenuBloc>(
          create: (context) =>
              MenuBloc(context.read<ApiClient>())..add(LoadMenu()),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(context.read<ApiClient>(), context),
        ),
        BlocProvider<AddApiBloc>(
          create: (context) => AddApiBloc(),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc(),
        ),
        BlocProvider<RolesBloc>(
          create: (context) => RolesBloc(context.read<ApiClient>()),
        ),
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(context.read<ApiClient>()),
        ),
        BlocProvider<MenuBloc>(
          create: (context) =>
              MenuBloc(context.read<ApiClient>())..add(LoadMenu()),
        ),
        BlocProvider<QueriesBloc>(
          create: (context) => QueriesBloc(context.read<ApiClient>()),
        ),
      ],
      child: BlocBuilder<LanguageBloc, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            locale: locale,
            title: 'Querier',
            debugShowCheckedModeBanner: false,
            theme: QuerierTheme.darkTheme,
            home: const LoginScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/users': (context) => const SettingUsersScreen(),
              '/roles': (context) => const SettingRolesScreen(),
              '/services': (context) => const SettingServicesScreen(),
              '/users/form': (context) {
                final user =
                    ModalRoute.of(context)?.settings.arguments as User?;
                return UserFormScreen(userToEdit: user);
              },
              '/roles/form': (context) {
                final role =
                    ModalRoute.of(context)?.settings.arguments as Role?;
                return RoleFormScreen(roleToEdit: role);
              },
              '/databases': (context) => const DatabasesScreen(),
              '/databases/form': (context) {
                final connection =
                    ModalRoute.of(context)?.settings.arguments as DBConnection?;
                return DatabaseFormScreen(connectionToEdit: connection);
              },
              '/databases/details': (context) {
                final connection =
                    ModalRoute.of(context)?.settings.arguments as DBConnection;
                return DatabaseDetailsScreen(connection: connection);
              },
              '/menu/categories': (context) => BlocProvider(
                    create: (context) => DynamicMenuCategoriesBloc(
                      context.read<ApiClient>(),
                      context,
                    ),
                    child: const DynamicMenuCategoriesScreen(),
                  ),
              '/menu/form': (context) {
                final category =
                    ModalRoute.of(context)?.settings.arguments as MenuCategory?;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: context.read<RolesBloc>(),
                    ),
                  ],
                  child: MenuCategoryFormScreen(categoryToEdit: category),
                );
              },
              '/queries': (context) => const QueriesScreen(),
              '/sql-query-form': (context) {
                final query =
                    ModalRoute.of(context)?.settings.arguments as SQLQuery?;
                return SQLQueryFormScreen(query: query);
              },
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
            ],
            navigatorKey: navigatorKey,
          );
        },
      ),
    );
  }
}

class SQLQueriesScreen {
  const SQLQueriesScreen();
}
// Add connection page in this code
// Add UI in different pages
