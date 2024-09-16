import 'package:flutter/material.dart';

class BuildOption extends StatelessWidget {
  final String title;
  final VoidCallback onTap; // Changed to VoidCallback for simplicity

  const BuildOption({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center, // Center the element
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, // Width 85% of the screen width
        margin: const EdgeInsets.symmetric(vertical: 4.0), // Margin between items
        padding: const EdgeInsets.all(6.0), // Padding inside the container
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7), // Background color with opacity
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4.0)], // Optional shadow
        ),
        child: SizedBox(
          height: 50, // Fixed height for each option
          child: ListTile(
            contentPadding: EdgeInsets.zero, // Remove default ListTile padding
            title: Text(
              title,
              style: const TextStyle(fontSize: 12), // Reduced font size
            ),
            onTap: onTap, // Use the onTap function here
          ),
        ),
      ),
    );
  }
}
