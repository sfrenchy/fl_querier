import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TranslationManager extends StatefulWidget {
  final Map<String, String> translations;
  final ValueChanged<Map<String, String>> onTranslationsChanged;

  const TranslationManager({
    Key? key,
    required this.translations,
    required this.onTranslationsChanged,
  }) : super(key: key);

  @override
  State<TranslationManager> createState() => _TranslationManagerState();
}

class _TranslationManagerState extends State<TranslationManager> {
  late Map<String, String> _translations;
  final List<String> _availableLanguages = ['en', 'fr'];  // Liste des langues disponibles

  @override
  void initState() {
    super.initState();
    _translations = Map.from(widget.translations);
  }

  void _addTranslation(String language) {
    setState(() {
      _translations[language] = '';
      widget.onTranslationsChanged(_translations);
    });
  }

  void _removeTranslation(String language) {
    setState(() {
      _translations.remove(language);
      widget.onTranslationsChanged(_translations);
    });
  }

  List<String> get _availableNewLanguages {
    return _availableLanguages.where((lang) => !_translations.containsKey(lang)).toList();
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableNewLanguages.map((lang) {
            String languageName = lang == 'en' ? 'English' : 'Français';
            return ListTile(
              leading: Text(
                lang.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              title: Text(languageName),
              onTap: () {
                Navigator.pop(context);
                _addTranslation(lang);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._translations.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: entry.value,
                    decoration: InputDecoration(
                      labelText: '${l10n.translatedName} (${entry.key})',
                    ),
                    onChanged: (value) {
                      _translations[entry.key] = value;
                      widget.onTranslationsChanged(_translations);
                    },
                  ),
                ),
                if (_translations.length > 1)  // Empêcher la suppression de la dernière traduction
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeTranslation(entry.key),
                  ),
              ],
            ),
          ),
        ),
        if (_availableNewLanguages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.addTranslation),
              onPressed: _showLanguageSelectionDialog,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              l10n.noMoreLanguagesAvailable,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
