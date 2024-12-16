// ignore_for_file: unnecessary_const, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/themes/styles.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'widgets/build_option.dart';
import 'widgets/notification_item.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'package:mobile/shared/state/app_state.dart' as appState;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeUser();
    appState.currentPage = 'home';
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      context.read<HomeBloc>().add(FetchTeamsFromCacheEvent());
      context.read<HomeBloc>().add(FetchTeamsEvent(userId));
    } else {
      context.read<HomeBloc>().add(FetchTeamsFromCacheEvent());
    }
  }

  @override
  void dispose() {
    _clearPlaceIdCache();
    super.dispose();
  }

  Future<void> _clearPlaceIdCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('placeId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(decoration: AppStyles.backgroundDecoration),
          // Filter overlay
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          // Main screen content
          Column(
            children: [
              // Logo at the top
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 25),
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: Image.asset('assets/logo_small.png'),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading || state is HomeInitial) {
                      return _buildLoadingView();
                    } else if (state is HomeLoaded) {
                      return _buildHomeContent(context, state.teams);
                    } else if (state is HomeError) {
                      return Center(
                        child: Text(
                          'Błąd: ${state.message}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              // Bottom Navigation
              BottomNavigation(
                onTap: (index) {
                  print("Navigation tapped: $index");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildHomeContent(BuildContext context, List<dynamic> teams) {
    return Column(
      children: [
        // Teams Section
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              color: AppStyles.transparentWhite,
            ),
            child: Column(
              children: [
                const Text(
                  'Wybierz budowę',
                  style: AppStyles.headerStyle,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      return BuildOption(
                        title: team['name'],
                        placeId: team['placeId'], // Pass placeId
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/construction_home',
                            arguments: {
                              'teamId': team['id'],
                              'placeId': team['placeId'],
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Notifications Section
        Expanded(
          flex: 4,
          child: Container(
            color: AppStyles.transparentWhite,
            child: Column(
              children: [
                const Text(
                  'Powiadomienia',
                  style: AppStyles.headerStyle,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: const [
                      NotificationItem(title: 'Powiadomienie 1'),
                      NotificationItem(title: 'Powiadomienie 2'),
                      NotificationItem(title: 'Powiadomienie 3'),
                      NotificationItem(title: 'Powiadomienie 4'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}