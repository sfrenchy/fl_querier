import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/widgets/user_avatar.dart';
import 'package:provider/provider.dart';
import 'package:querier/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: UserAvatar(
                firstName: authProvider.firstName ?? '',
                lastName: authProvider.lastName ?? '',
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(l10n.name),
                      subtitle: Text(
                          '${authProvider.firstName} ${authProvider.lastName}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(l10n.email),
                      subtitle: Text(authProvider.userEmail ?? ''),
                    ),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: Text(l10n.roles),
                      subtitle: Text(authProvider.userRoles.join(', ')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
