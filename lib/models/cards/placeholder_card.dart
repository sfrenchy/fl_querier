import 'package:querier/models/dynamic_card.dart';

class PlaceholderCard extends DynamicCard {
  static const defaultLabel = <String, String>{
    'en': 'Placeholder',
    'fr': 'Espace réservé'
  };

  Map<String, String> get label => 
    (configuration['label'] as Map<String, dynamic>?)?.cast<String, String>() ?? 
    defaultLabel;

  const PlaceholderCard({
    required super.id,
    required super.titles,
    required super.order,
    super.gridWidth,
    super.backgroundColor,
    super.textColor,
    Map<String, dynamic>? configuration,
  }) : super(
    type: 'Placeholder',
    configuration: configuration ?? const {'label': <String, String>{
      'en': 'Placeholder',
      'fr': 'Espace réservé'
    }},
  );

  String getLocalizedLabel(String languageCode) {
    return label[languageCode] ?? label['en'] ?? '';
  }

  @override
  Map<String, dynamic> get specificConfiguration => {
    'label': label,
  };
}
