import 'package:querier/models/role.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isEmailConfirmed;
  final List<Role> roles;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isEmailConfirmed,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['Id'] ?? '',
      email: json['Email'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      isEmailConfirmed: json['IsEmailConfirmed'] ?? false,
      roles: (json['Roles'] as List<dynamic>? ?? []).map((r) {
        if (r is String) {
          return Role(id: '', name: r);
        } else {
          return Role.fromJson(r as Map<String, dynamic>);
        }
      }).toList(),
    );
  }
}
