import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IconSelector extends StatelessWidget {
  final String icon;
  final ValueChanged<String> onIconSelected;

  const IconSelector({
    super.key,
    required this.icon,
    required this.onIconSelected,
  });

  static const _commonIcons = {
    // Navigation
    'home': Icons.home,
    'menu': Icons.menu,
    'dashboard': Icons.dashboard,
    'list': Icons.list,
    'grid_view': Icons.grid_view,

    // Actions
    'settings': Icons.settings,
    'search': Icons.search,
    'add': Icons.add_box,
    'edit': Icons.edit,
    'delete': Icons.delete,

    // Content
    'folder': Icons.folder,
    'file': Icons.insert_drive_file,
    'document': Icons.description,
    'table': Icons.table_chart,
    'chart': Icons.bar_chart,
    'analytics': Icons.analytics,

    // Users & Security
    'person': Icons.person,
    'group': Icons.group,
    'security': Icons.security,
    'admin': Icons.admin_panel_settings,
    'key': Icons.vpn_key,

    // Database
    'database': Icons.storage,
    'data': Icons.data_array,
    'backup': Icons.backup,
    'sync': Icons.sync,

    // Communication
    'email': Icons.email,
    'message': Icons.message,
    'notification': Icons.notifications,
    'chat': Icons.chat,

    // Organization
    'category': Icons.category,
    'tag': Icons.tag,
    'label': Icons.label,
    'bookmark': Icons.bookmark,

    // Development
    'code': Icons.code,
    'api': Icons.api,
    'bug': Icons.bug_report,
    'terminal': Icons.terminal,

    // Misc
    'info': Icons.info,
    'help': Icons.help,
    'warning': Icons.warning,
    'error': Icons.error,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: Icon(getIconData(icon)),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.selectIcon),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                children: _commonIcons.entries.map((entry) {
                  return InkWell(
                    onTap: () {
                      onIconSelected(entry.key);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(entry.value),
                          const SizedBox(height: 4),
                          Text(
                            entry.key,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'menu':
        return Icons.menu;
      default:
        return Icons.error;
    }
  }
}
