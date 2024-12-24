import 'package:querier/models/dynamic_row.dart';

class Layout {
  final int pageId;
  final String icon;
  final Map<String, String> names;
  final bool isVisible;
  final List<String> roles;
  final String route;
  final List<DynamicRow> rows;

  Layout({
    required this.pageId,
    required this.icon,
    required this.names,
    required this.isVisible,
    required this.roles,
    required this.route,
    required this.rows,
  });

  factory Layout.fromJson(Map<String, dynamic> json) {
    return Layout(
      pageId: json['PageId'],
      icon: json['Icon'],
      names: Map<String, String>.from(json['Names']),
      isVisible: json['IsVisible'],
      roles: List<String>.from(json['Roles']),
      route: json['Route'],
      rows: (json['Rows'] as List)
          .map((row) => DynamicRow.fromJson(row))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'PageId': pageId,
        'Icon': icon,
        'Names': names,
        'IsVisible': isVisible,
        'Roles': roles,
        'Route': route,
        'Rows': rows.map((row) => row.toJson()).toList(),
      };

  Layout copyWith({
    int? pageId,
    String? icon,
    Map<String, String>? names,
    bool? isVisible,
    List<String>? roles,
    String? route,
    List<DynamicRow>? rows,
  }) {
    return Layout(
      pageId: pageId ?? this.pageId,
      icon: icon ?? this.icon,
      names: names ?? this.names,
      isVisible: isVisible ?? this.isVisible,
      roles: roles ?? this.roles,
      route: route ?? this.route,
      rows: rows ?? this.rows,
    );
  }
}
