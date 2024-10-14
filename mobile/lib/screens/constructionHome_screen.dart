import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart';

class ConstructionHomeScreen extends StatefulWidget {
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
          // Czarny filtr z przezroczystością
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // Main content
          Column(
            children: [
              // Full header with background and title
              Container(
                width: double.infinity,
                color: AppStyles.transparentWhite,
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appState.selectedConstructionName,
                      style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        appState.isConstructionContext = false;
                        appState.selectedConstructionName = '';
                        Navigator.pushNamed(context, '/home');
                      },
                    ),
                  ],
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
                      Text('Szczegóły budowy:', style: AppStyles.headerStyle),
                      SizedBox(height: 8),
                      Text(
                        'Opis inwestycji i wszelkie istotne informacje dotyczące tej budowy.',
                        style: AppStyles.textStyle,
                      ),
                      Spacer(),
                      // Button to navigate to chat, placed just above the bottom navigation
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0.0), // Zmniejszony padding do 0
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/chat');
                            },
                            icon: Icon(Icons.chat, color: Colors.black),
                            label: Text('Przejdź do czatu', style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700]!.withOpacity(0.3), // Bardziej przezroczyste tło
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 60.0),
                              textStyle: TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
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
