import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/profile/models/user_model.dart';
import 'package:mobile/shared/themes/styles.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/profile_item.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final profileBloc = context.read<ProfileBloc>();
    profileBloc.add(FetchProfileFromCacheEvent());

    Future.delayed(const Duration(milliseconds: 500), () {
      profileBloc.add(FetchProfileEvent());
    });
  }

  void _logout() {
    context.read<ProfileBloc>().add(LogoutEvent());
  }

  void _showEditProfileDialog(User profile) {
  showDialog(
    context: context,
    builder: (_) => EditProfileDialog(
      user: profile,
      onSave: (updatedProfile) {
        context.read<ProfileBloc>().add(EditProfileEvent(updatedProfile));
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dodanie tła jak w ChatListScreen
          Positioned.fill(
            child: Container(decoration: AppStyles.backgroundDecoration),
          ),
          Positioned.fill(
            child: Container(color: AppStyles.filterColor.withOpacity(0.75)),
          ),
          // Dodanie przezroczystego białego tła
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite, // Przezroczyste białe tło
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ProfileLoaded) {
                          final profile = state.profile;
                          return _buildProfileContent(profile);
                        } else if (state is LogoutSuccess) {
                          Future.microtask(() {
                            Navigator.pushReplacementNamed(context, '/');
                          });
                          return const SizedBox.shrink();
                        } else if (state is ProfileError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                // Dolna nawigacja
                BottomNavigation(onTap: (index) {
                  print("Navigation tapped: $index");
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildProfileContent(User profile) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.userImageUrl.isNotEmpty
                ? NetworkImage(profile.userImageUrl)
                : null,
            child: profile.userImageUrl.isEmpty
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            '${profile.name} ${profile.surname}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          ProfileItem(icon: Icons.email, title: profile.email),
          ProfileItem(icon: Icons.phone, title: profile.telephoneNr),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showEditProfileDialog(profile),
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
  );
}
}
