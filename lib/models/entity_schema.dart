class EntityProperty {
  final String name;
  final String type;
  final List<dynamic> options;
  final dynamic availableItems;

  EntityProperty({
    required this.name,
    required this.type,
    required this.options,
    this.availableItems,
  });

  factory EntityProperty.fromJson(Map<String, dynamic> json) {
    return EntityProperty(
      name: json['Name'],
      type: json['Type'],
      options: json['Options'] ?? [],
      availableItems: json['AvailableItems'],
    );
  }
}

class EntitySchema {
  final String name;
  final List<EntityProperty> properties;

  EntitySchema({
    required this.name,
    required this.properties,
  });

  factory EntitySchema.fromJson(Map<String, dynamic> json) {
    return EntitySchema(
      name: json['Name'],
      properties: (json['Properties'] as List)
          .map((prop) => EntityProperty.fromJson(prop))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Properties': properties.map((p) => {
        'Name': p.name,
        'Type': p.type,
        'Options': p.options,
        'AvailableItems': p.availableItems,
      }).toList(),
    };
  }
} 