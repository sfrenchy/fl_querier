import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? dragHandle;
  final Color? textColor;
  final Color? backgroundColor;
  final bool isEditing;

  const CardHeader({
    Key? key,
    required this.title,
    this.onEdit,
    this.onDelete,
    this.dragHandle,
    this.textColor,
    this.backgroundColor,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(4.0),
        ),
      ),
      child: Row(
        children: [
          if (isEditing && dragHandle != null) dragHandle!,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          if (isEditing) ...[
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                color: textColor,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                color: textColor,
              ),
          ],
        ],
      ),
    );
  }
}
