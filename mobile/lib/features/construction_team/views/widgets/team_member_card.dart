import 'package:flutter/material.dart';

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String phone;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    required this.phone,
  });

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
        subtitle: Text(role),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            // Tutaj można dodać logikę dzwonienia, np. używając `url_launcher`
          },
        ),
      ),
    );
  }
}
