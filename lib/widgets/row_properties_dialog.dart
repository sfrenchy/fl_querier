import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:querier/models/dynamic_row.dart';

class RowPropertiesDialog extends StatefulWidget {
  final DynamicRow row;
  final Function(MainAxisAlignment, CrossAxisAlignment, double) onSave;

  const RowPropertiesDialog({
    super.key,
    required this.row,
    required this.onSave,
  });

  @override
  State<RowPropertiesDialog> createState() => _RowPropertiesDialogState();
}

class _RowPropertiesDialogState extends State<RowPropertiesDialog> {
  late MainAxisAlignment _alignment;
  late CrossAxisAlignment _crossAlignment;
  late double _spacing;

  @override
  void initState() {
    super.initState();
    _alignment = widget.row.alignment;
    _crossAlignment = widget.row.crossAlignment;
    _spacing = widget.row.spacing;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.rowProperties),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<MainAxisAlignment>(
            value: _alignment,
            decoration: InputDecoration(
              labelText: l10n.horizontalAlignment,
            ),
            items: MainAxisAlignment.values.map((alignment) {
              return DropdownMenuItem(
                value: alignment,
                child: Text(alignment.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _alignment = value);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<CrossAxisAlignment>(
            value: _crossAlignment,
            decoration: InputDecoration(
              labelText: l10n.verticalAlignment,
            ),
            items: CrossAxisAlignment.values.map((alignment) {
              return DropdownMenuItem(
                value: alignment,
                child: Text(alignment.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _crossAlignment = value);
              }
            },
          ),
          const SizedBox(height: 16),
          Slider(
            value: _spacing,
            min: 0,
            max: 32,
            divisions: 32,
            label: _spacing.toString(),
            onChanged: (value) {
              setState(() => _spacing = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_alignment, _crossAlignment, _spacing);
            Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
