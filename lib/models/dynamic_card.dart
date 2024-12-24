import 'package:querier/models/cards/base_card.dart';

class DynamicCard extends BaseCard {
  final int gridWidth;
  final int? backgroundColor;
  final int? textColor;
  final int? headerTextColor;
  final int? headerBackgroundColor;
  final Map<String, dynamic> configuration;

  const DynamicCard({
    required super.id,
    required super.titles,
    required super.order,
    required super.type,
    this.gridWidth = 12,
    this.backgroundColor,
    this.textColor,
    this.headerTextColor,
    this.headerBackgroundColor,
    this.configuration = const {},
  });

  @override
  Map<String, dynamic> get specificConfiguration => configuration;

  factory DynamicCard.fromJson(Map<String, dynamic> json) {
    print('DynamicCard.fromJson: raw json = $json');
    print('HeaderBackgroundColor from json: ${json['HeaderBackgroundColor']}');

    return DynamicCard(
      id: json['Id'],
      titles: Map<String, String>.from(json['Titles']),
      order: json['Order'],
      type: json['Type'],
      gridWidth: json['GridWidth'] ?? 12,
      backgroundColor: json['BackgroundColor'],
      textColor: json['TextColor'],
      headerTextColor: json['HeaderTextColor'],
      headerBackgroundColor: json['HeaderBackgroundColor'],
      configuration: Map<String, dynamic>.from(json['Configuration'] ?? {}),
    );
  }

  @override
  DynamicCard copyWith({
    int? id,
    Map<String, String>? titles,
    int? order,
    int? gridWidth,
    int? backgroundColor,
    int? textColor,
    int? headerBackgroundColor,
    int? headerTextColor,
    Map<String, dynamic>? configuration,
  }) {
    print('DynamicCard.copyWith: gridWidth parameter = $gridWidth'); // Debug

    return DynamicCard(
      id: id ?? this.id,
      titles: titles ?? this.titles,
      order: order ?? this.order,
      gridWidth: gridWidth ?? this.gridWidth,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      configuration: configuration ?? this.configuration,
      type: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Titles': titles,
      'Order': order,
      'Type': type,
      'GridWidth': gridWidth,
      'BackgroundColor': backgroundColor,
      'TextColor': textColor,
      'HeaderBackgroundColor': headerBackgroundColor,
      'HeaderTextColor': headerTextColor,
      'Configuration': configuration,
    };
  }
}
