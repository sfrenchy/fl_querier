import 'package:flutter/material.dart';

class MenuPage {
  final int id;
  final Map<String, String> names;
  final String icon;
  final int order;
  bool isVisible;
  final List<String> roles;
  final String route;
  final int menuCategoryId;

  MenuPage({
    required this.id,
    required this.names,
    required this.icon,
    required this.order,
    required this.isVisible,
    required this.roles,
    required this.route,
    required this.menuCategoryId,
  });

  String getLocalizedName(String languageCode) {
    return names[languageCode] ?? names['en'] ?? '';
  }

  IconData getIconData() {
    switch (icon) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      default:
        return Icons.error;
    }
  }

  factory MenuPage.fromJson(Map<String, dynamic> json) {
    return MenuPage(
      id: json['Id'] ?? 0,
      names: Map<String, String>.from(json['Names'] ?? {}),
      icon: json['Icon'] ?? '',
      order: json['Order'] ?? 0,
      isVisible: json['IsVisible'] ?? false,
      roles: List<String>.from(json['Roles'] ?? []),
      route: json['Route'] ?? '',
      menuCategoryId: json['DynamicMenuCategoryId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Names': names,
        'Icon': icon,
        'Order': order,
        'IsVisible': isVisible,
        'Roles': roles,
        'Route': route,
        'DynamicMenuCategoryId': menuCategoryId,
      };
}
