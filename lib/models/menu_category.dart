import 'package:flutter/material.dart';
import 'package:querier/models/page.dart';

class MenuCategory {
  final int Id;
  final Map<String, String> names;
  final String icon;
  final int order;
  final bool isVisible;
  final List<String> roles;
  final String route;
  final List<MenuPage> pages;

  MenuCategory({
    required this.Id,
    required this.names,
    required this.icon,
    required this.order,
    required this.isVisible,
    required this.roles,
    required this.route,
    required this.pages,
  });

  String getLocalizedName(String languageCode) {
    return names[languageCode] ?? names['en'] ?? '';
  }

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    print('MenuCategory.fromJson: ${json['Pages']}'); // Debug
    return MenuCategory(
      Id: json['Id'],
      names: Map<String, String>.from(json['Names']),
      icon: json['Icon'],
      order: json['Order'],
      isVisible: json['IsVisible'],
      roles: List<String>.from(json['Roles']),
      route: json['Route'],
      pages:
          (json['Pages'] as List?)?.map((p) => MenuPage.fromJson(p)).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() => {
        'Id': Id,
        'Names': names,
        'Icon': icon,
        'Order': order,
        'IsVisible': isVisible,
        'Roles': roles,
        'Route': route,
        'Pages': pages.map((p) => p.toJson()).toList(),
      };

  IconData getIconData() {
    switch (icon) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'menu':
        return Icons.menu;
      default:
        return Icons.error;
    }
  }

  MenuCategory copyWith({
    bool? isVisible,
  }) {
    return MenuCategory(
      Id: Id,
      names: names,
      icon: icon,
      order: order,
      isVisible: isVisible ?? this.isVisible,
      roles: roles,
      route: route,
      pages: pages,
    );
  }
}
