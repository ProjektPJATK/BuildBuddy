import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart'; // Import the AppStyles

class ConstructionHomeScreen extends StatefulWidget {
  const ConstructionHomeScreen({super.key});

  @override
  _ConstructionHomeScreenState createState() => _ConstructionHomeScreenState();
}

class _ConstructionHomeScreenState extends State<ConstructionHomeScreen> {
  @override
  void initState() {
    super.initState();
    appState.currentPage = 'construction_home';
    appState.isConstructionContext = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Black filter with opacity
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // Main content
          Column(
            children: [
              // Full header with background and title (without back arrow)
              Container(
                width: double.infinity,
                color: AppStyles.transparentWhite,
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
                child: Text(
                  appState.selectedConstructionName,
                  style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                ),
              ),
              // Full background for details section
              Expanded(
                child: Container(
                  color: AppStyles.transparentWhite,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Szczegóły budowy:', style: AppStyles.headerStyle),
                      const SizedBox(height: 8),
                      const Text(
                        'Opis inwestycji i wszelkie istotne informacje dotyczące tej budowy.',
                        style: AppStyles.textStyle,
                      ),
                      const Spacer(),
                      // Button to navigate to chat, placed just above the bottom navigation
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0.0), // Reduced bottom padding to 0
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/chat');
                            },
                            icon: const Icon(Icons.chat, color: Colors.white), // White icon for consistency
                            label: const Text('Przejdź do czatu', style: TextStyle(color: Colors.white)),
                            style: AppStyles.buttonStyle().copyWith(
                              backgroundColor: MaterialStateProperty.all(Colors.grey[700]!.withOpacity(0.3)),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 60.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BottomNavigation(
                onTap: (_) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
