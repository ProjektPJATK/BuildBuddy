import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';
import '../services/user_service.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/profile_item.dart';

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
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await UserService.getUserProfile();
      setState(() {
        name = userProfile['name'];
        surname = userProfile['surname'];
        email = userProfile['mail'];
        phone = userProfile['telephoneNr'];
        profileImageUrl = userProfile['userImageUrl'];
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się załadować danych profilu.')),
      );
    }
  }

  Future<void> _logout() async {
    await UserService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        name: name,
        surname: surname,
        email: email,
        phone: phone,
        onSave: (updatedProfile) {
          setState(() {
            name = updatedProfile['name'];
            surname = updatedProfile['surname'];
            email = updatedProfile['mail'];
            phone = updatedProfile['telephoneNr'];
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 30),
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: profileImageUrl != null
                                    ? NetworkImage(profileImageUrl!)
                                    : null,
                                child: profileImageUrl == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '$name $surname',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              ProfileItem(icon: Icons.email, title: email ?? 'N/A'),
                              ProfileItem(icon: Icons.phone, title: phone ?? 'N/A'),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _showEditProfileDialog,
                                child: const Text('EDYTUJ PROFIL'),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _logout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('WYLOGUJ SIĘ'),
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
    );
  }
}
