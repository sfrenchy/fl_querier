abstract class BaseCard {
  final int id;
  final Map<String, String> titles;
  final int order;
  final String type;
  final int gridWidth;
  final int? backgroundColor;
  final int? textColor;

  const BaseCard({
    required this.id,
    required this.titles,
    required this.order,
    required this.type,
    this.gridWidth = 12,
    this.backgroundColor,
    this.textColor,
  });

  Map<String, dynamic> get specificConfiguration;

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Titles': titles,
        'Order': order,
        'Type': type,
        'GridWidth': gridWidth,
        'BackgroundColor': backgroundColor,
        'TextColor': textColor,
        'Configuration': specificConfiguration,
      };

  String getLocalizedTitle(String languageCode) {
    return titles[languageCode] ?? titles['en'] ?? '';
  }
}
