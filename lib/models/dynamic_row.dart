import 'package:flutter/material.dart';
import 'package:querier/models/dynamic_card.dart';

extension AlignmentExtension on MainAxisAlignment {
  String toJson() {
    return name[0].toUpperCase() + name.substring(1);
  }
}

extension CrossAlignmentExtension on CrossAxisAlignment {
  String toJson() {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class DynamicRow {
  final int id;
  final int pageId;
  final int order;
  final MainAxisAlignment alignment;
  final CrossAxisAlignment crossAlignment;
  final double spacing;
  final double? height;
  final List<DynamicCard> cards;

  const DynamicRow({
    required this.id,
    required this.pageId,
    required this.order,
    this.alignment = MainAxisAlignment.start,
    this.crossAlignment = CrossAxisAlignment.start,
    this.spacing = 16.0,
    this.height,
    this.cards = const [],
  });

  factory DynamicRow.fromJson(Map<String, dynamic> json) {
    try {
      final row = DynamicRow(
        id: json['Id'] ?? 0,
        pageId: json['PageId'] ?? 0,
        order: json['Order'] ?? 0,
        alignment: _parseMainAxisAlignment(json['Alignment']),
        crossAlignment: _parseCrossAxisAlignment(json['CrossAlignment']),
        spacing: json['Spacing']?.toDouble() ?? 16.0,
        height: json['Height']?.toDouble(),
        cards: (json['Cards'] as List?)?.map((card) {
              return DynamicCard.fromJson(card as Map<String, dynamic>);
            }).toList() ??
            const [],
      );
      return row;
    } catch (e) {
      print('Error in DynamicRow.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'PageId': pageId,
        'Order': order,
        'Height': height,
        'Cards': cards.map((card) => card.toJson()).toList(),
      };

  DynamicRow copyWith({
    int? id,
    int? pageId,
    int? order,
    MainAxisAlignment? alignment,
    CrossAxisAlignment? crossAlignment,
    double? spacing,
    double? height,
    List<DynamicCard>? cards,
  }) {
    return DynamicRow(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      order: order ?? this.order,
      alignment: alignment ?? this.alignment,
      crossAlignment: crossAlignment ?? this.crossAlignment,
      spacing: spacing ?? this.spacing,
      height: height ?? this.height,
      cards: cards ?? this.cards,
    );
  }

  static MainAxisAlignment _parseMainAxisAlignment(String? value) {
    return MainAxisAlignment.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MainAxisAlignment.start,
    );
  }

  static CrossAxisAlignment _parseCrossAxisAlignment(String? value) {
    return CrossAxisAlignment.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CrossAxisAlignment.start,
    );
  }
}
