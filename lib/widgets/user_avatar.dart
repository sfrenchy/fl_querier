import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    this.size = 40,
    this.onTap,
  });

  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
