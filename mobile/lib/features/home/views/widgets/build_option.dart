import 'package:flutter/material.dart';

class BuildOption extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const BuildOption({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4.0)],
        ),
        child: SizedBox(
          height: 50,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
