import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart'; // Import the BottomNavigation widget

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Background Image with transparency
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay to darken the background slightly
          Container(
            color: Colors.black.withOpacity(0.3), // Adjust transparency here
          ),
          // Content
          Column(
            children: [
              SizedBox(height: 80), // Space from top for status bar
              // White semi-transparent card section
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 30), // Padding from top of card
                        // Profile Name and Picture section
                        Column(
                          children: [
                            // Name above the profile image
                            Text(
                              'Jan Kowalski',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Adjust text color if needed
                              ),
                            ),
                            SizedBox(height: 10),
                            // Profile Image
                            CircleAvatar(
                              radius: 50, // Adjust the size of the profile image
                              backgroundImage: AssetImage('assets/profile_picture.jpg'), // Replace with the uploaded profile picture
                            ),
                          ],
                        ),
                        SizedBox(height: 30), // Space below profile image and name
                        // Profile details
                        profileItem(
                          icon: Icons.person,
                          title: 'Jan Kowalski',
                        ),
                        profileItem(
                          icon: Icons.cake,
                          title: 'Urodziny',
                        ),
                        profileItem(
                          icon: Icons.phone,
                          title: '+48 111 111 111',
                        ),
                        profileItem(
                          icon: Icons.email,
                          title: 'jan.kowalski@gmail.com',
                        ),
                        profileItem(
                          icon: Icons.lock,
                          title: 'Hasło',
                        ),
                        profileItem(
                          icon: Icons.people,
                          title: 'Zespoły',
                          trailing: Icon(Icons.edit, color: Color(0xFF424242)),
                        ),
                        SizedBox(height: 20),
                        // Edit Profile button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            child: Text(
                              'EDYTUJ PROFIL',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          // Define navigation logic here based on the index
        },
      ),
    );
  }

  // Helper widget for each profile item
  Widget profileItem({required IconData icon, required String title, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Color(0xFF424242)), // Set icon color to #424242
          SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242), // Set text color to #424242
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
