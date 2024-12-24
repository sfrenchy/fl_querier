import 'package:flutter/material.dart';
import 'package:querier/models/cards/base_card.dart';
import 'package:querier/models/dynamic_card.dart';
import 'package:querier/widgets/cards/card_header.dart';

abstract class BaseCardWidget extends StatelessWidget {
  final DynamicCard card;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? dragHandle;
  final bool isEditing;
  final double? maxRowHeight;

  // Nouveaux getters optionnels pour header/footer
  Widget? buildHeader(BuildContext context) => null;
  Widget? buildFooter(BuildContext context) => null;

  // Le contenu principal de la carte (obligatoire)
  Widget buildCardContent(BuildContext context);

  const BaseCardWidget({
    super.key,
    required this.card,
    this.onEdit,
    this.onDelete,
    this.dragHandle,
    this.isEditing = false,
    this.maxRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: card.backgroundColor != null ? Color(card.backgroundColor!) : null,
      child: SizedBox(
        height: maxRowHeight! - 26,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            CardHeader(
              title: card.getLocalizedTitle(
                Localizations.localeOf(context).languageCode,
              ),
              onEdit: isEditing ? onEdit : null,
              onDelete: isEditing ? onDelete : null,
              dragHandle: isEditing ? dragHandle : null,
              isEditing: isEditing,
              backgroundColor: card.headerBackgroundColor != null
                  ? Color(card.headerBackgroundColor!)
                  : null,
              textColor: card.headerTextColor != null
                  ? Color(card.headerTextColor!)
                  : null,
            ),
            Expanded(child: buildCardContent(context)),
            if (buildFooter(context) != null) buildFooter(context)!,
          ],
        ),
      ),
    );
  }
}
