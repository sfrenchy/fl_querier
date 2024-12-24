class Role {
  final String id;
  final String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
    );
  }
}
