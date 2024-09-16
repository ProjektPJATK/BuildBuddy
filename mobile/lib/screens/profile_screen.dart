import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart'; // Import stylów

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    appState.currentPage = 'profile'; // Ustawiamy aktualną stronę na profil

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Filter
          Container(
            color: AppStyles.filterColor.withOpacity(0.75), // Użycie ciemniejszego filtru
          ),
          // Screen content
          Column(
            children: [
              // Profil od góry ekranu
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: AppStyles.transparentWhite, // Białe tło z przezroczystością
                    child: Column(
                      children: [
                        SizedBox(height: 50), // Margines od góry na status bar
                        // Profile Name and Picture section
                        Column(
                          children: [
                            // Name above the profile image
                            Text(
                              'Jan Kowalski',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            // Profile Image
                            CircleAvatar(
                              radius: 50, // Rozmiar zdjęcia profilowego
                              backgroundColor: Colors.grey[300], // Dodaj szare tło
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/profile_picture.png',
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                    return Icon(Icons.person, size: 50, color: Colors.grey); // Ikona zastępcza
                                  },
                                ),
                              ),
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
                        SizedBox(height: 20), // Dodajemy odstęp na dole zawartości
                      ],
                    ),
                  ),
                ),
              ),
              // Pasek nawigacyjny na dole
              BottomNavigation(
                onTap: (int index) {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/calendar');
                  } else if (index == 1) {
                    Navigator.pushNamed(context, '/chat');
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/home');
                  } else if (index == 3) {
                    Navigator.pushNamed(context, '/profile');
                  }
                },
                noBackground: false, // Tło dla paska, tak jak w HomeScreen
              ),
            ],
          ),
        ],
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
