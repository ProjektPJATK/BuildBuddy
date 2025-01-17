import 'package:flutter/material.dart';

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final Function()? onInfoPressed;

  const TeamMemberCard({
    Key? key,
    required this.name,
    required this.role,
    required this.phone,
    this.onInfoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(role ?? 'Brak roli'),
        trailing: onInfoPressed != null
            ? IconButton(
                icon: const Icon(Icons.info),
                onPressed: onInfoPressed,
              )
            : null, // Ukryj ikonę, jeśli brak akcji
      ),
    );
  }
}
