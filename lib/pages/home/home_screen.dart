import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/api/api_client.dart';
import 'package:querier/blocs/menu_bloc.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_page_layout_bloc.dart';
import 'package:querier/pages/settings/menu/pages/bloc/dynamic_page_layout_event.dart';
import 'package:querier/widgets/app_drawer.dart';
import 'package:querier/widgets/cards/card_selector.dart';
import 'package:querier/widgets/draggable_row.dart';
import 'package:querier/widgets/menu_drawer.dart';
import 'package:querier/widgets/user_avatar.dart';
import 'bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pageId = ModalRoute.of(context)?.settings.arguments as int? ?? 1;

    context.read<MenuBloc>().add(LoadMenu());

    return BlocProvider(
      create: (context) =>
          HomeBloc(context.read<ApiClient>())..add(LoadDashboard(pageId)),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(child: Text(state.message));
          }

          if (state is HomeLoaded) {
            return Scaffold(
              appBar: AppBar(
                leading: Builder(
                  builder: (BuildContext context) => IconButton(
                    icon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/querier_logo_no_bg_big.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UserAvatar(
                      firstName: state.firstName,
                      lastName: state.lastName,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ),
                ],
              ),
              drawer: const AppDrawer(),
              body: RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(RefreshDashboard(pageId));
                },
                child: Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        ...state.rows.map((row) => DraggableRow(
                              key: ValueKey(row.id),
                              row: row,
                              isEditing: false,
                              onEdit: () => {},
                              onDelete: () => {},
                              onReorder: (oldIndex, newIndex) {},
                              onAcceptCard: (cardData) {},
                              onReorderCards: (rowId, oldIndex, newIndex) {},
                              onRowUpdated: (updatedRow) {},
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
