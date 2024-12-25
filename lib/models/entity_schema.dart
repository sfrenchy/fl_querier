class EntitySchema {
  final String name;
  final List<PropertyDefinition> properties;

  EntitySchema({
    required this.name,
    required this.properties,
  });

  factory EntitySchema.fromJson(Map<String, dynamic> json) {
    return EntitySchema(
      name: json['Name']?.toString() ?? 'Unknown',
      properties: (json['Properties'] as List?)
          ?.map((p) => PropertyDefinition.fromJson(p))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'Name': name,
    'Properties': properties.map((p) => {
      'Name': p.name,
      'Type': p.type,
      'Options': p.options,
    }).toList(),
  };
}

class PropertyDefinition {
  final String name;
  final String type;
  final List<String> options;

  PropertyDefinition({
    required this.name,
    required this.type,
    required this.options,
  });

  factory PropertyDefinition.fromJson(Map<String, dynamic> json) {
    return PropertyDefinition(
      name: json['Name']?.toString() ?? '',
      type: json['Type']?.toString() ?? 'String',
      options: (json['Options'] as List?)
          ?.map((o) => o.toString())
          .toList() ?? [],
    );
  }
} 