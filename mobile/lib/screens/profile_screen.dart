import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart'; // Import styles

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? name;
  String? surname;
  String? email;
  String? phone;
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user profile on screen load
  }

  // Logout logic
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove the token from SharedPreferences
    await prefs.remove('userId'); // Remove userId from SharedPreferences

    // Navigate back to the login screen
    Navigator.pushReplacementNamed(context, '/');
  }

  // Load user profile information from backend
  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please log in again.')),
      );
      _logout(context);
      return;
    }

    final url = "http://10.0.2.2:5007/api/User/$userId"; // Adjust backend IP and port if necessary

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'accept': 'text/plain',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          name = data['name'];
          surname = data['surname'];
          email = data['mail'];
          phone = data['telephoneNr'];
          profileImageUrl = data['userImageUrl'];
          isLoading = false; // Data loaded successfully
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while loading profile data.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    appState.currentPage = 'profile'; // Set the current page to 'profile'

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Filter
          Container(
            color: AppStyles.filterColor.withOpacity(0.75), // Apply darker filter
          ),
          // Screen content
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading indicator while loading
              : Column(
                  children: [
                    // Profile section
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          color: AppStyles.transparentWhite, // Semi-transparent white background
                          child: Column(
                            children: [
                              const SizedBox(height: 50), // Space at the top
                              // Profile Name and Picture
                              Column(
                                children: [
                                  Text(
                                    '$name $surname',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  CircleAvatar(
                                    radius: 50, // Profile image size
                                    backgroundColor: Colors.grey[300], // Background color for profile picture
                                    child: ClipOval(
                                      child: profileImageUrl != null
                                          ? Image.network(
                                              profileImageUrl!,
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                return const Icon(Icons.person, size: 50, color: Colors.grey); // Placeholder icon
                                              },
                                            )
                                          : const Icon(Icons.person, size: 50, color: Colors.grey), // Placeholder icon
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30), // Space between profile image and details
                              // Profile Details
                              profileItem(
                                icon: Icons.person,
                                title: '$name $surname',
                              ),
                              profileItem(
                                icon: Icons.cake,
                                title: 'Urodziny',
                              ),
                              profileItem(
                                icon: Icons.phone,
                                title: phone ?? 'N/A',
                              ),
                              profileItem(
                                icon: Icons.email,
                                title: email ?? 'N/A',
                              ),
                              profileItem(
                                icon: Icons.people,
                                title: 'Zespoły',
                                trailing: const Icon(Icons.edit, color: Color(0xFF424242)),
                              ),
                              const SizedBox(height: 20),
                              // Button Row: Edit Profile and Logout Buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Edit profile functionality
                                        },
                                        style: AppStyles.buttonStyle().copyWith(
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          textStyle: MaterialStateProperty.all(
                                            const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        child: const Text(
                                          'EDYTUJ PROFIL',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16), // Space between buttons
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _logout(context), // Call logout function
                                        style: AppStyles.buttonStyle().copyWith(
                                          backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 39, 177, 241)),
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          textStyle: MaterialStateProperty.all(
                                            const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        child: const Text(
                                          'WYLOGUJ SIĘ',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20), // Space at the bottom
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom Navigation Bar
                    BottomNavigation(
                      onTap: (_) {}, // Empty function to avoid 'null' error
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // Helper widget for profile details
  Widget profileItem({required IconData icon, required String title, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF424242)), // Icon color set to #424242
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242), // Text color set to #424242
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
