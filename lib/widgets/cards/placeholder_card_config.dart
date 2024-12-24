import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/models/cards/placeholder_card.dart';
import 'package:querier/widgets/translation_manager.dart';

class PlaceholderCardConfig extends StatelessWidget {
  final PlaceholderCard card;
  final ValueChanged<Map<String, dynamic>> onConfigurationChanged;

  const PlaceholderCardConfig({
    Key? key,
    required this.card,
    required this.onConfigurationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cardLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TranslationManager(
          translations: card.label,
          onTranslationsChanged: (newLabel) {
            onConfigurationChanged({'label': newLabel});
          },
        ),
      ],
    );
  }
} 