// lib/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Map<String, dynamic>> inventoryItems = [
    {'name': 'Cement', 'purchased': 100, 'remaining': 50},
    {'name': 'Farba', 'purchased': 20, 'remaining': 15},
    {'name': 'Deski', 'purchased': 200, 'remaining': 150},
    {'name': 'Kostka brukowa', 'purchased': 300, 'remaining': 280},
  ];

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = inventoryItems;
    appState.currentPage = 'construction_inventory';
  }

  void _filterInventory(String query) {
    final results = inventoryItems
        .where((item) => item['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredItems = results;
    });
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
          // Filter
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // Main content with semi-transparent white background covering the entire screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Full header background
                Container(
                  color: AppStyles.transparentWhite,
                  width: double.infinity, // Fill the full width
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                  child: Text(
                    'Inwentarz budowy',
                    style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                  ),
                ),
                // Search bar with background
                Container(
                  color: AppStyles.transparentWhite, // Add background for the search bar
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterInventory,
                    decoration: InputDecoration(
                      hintText: 'Wyszukaj przedmioty...',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                // Inventory list
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white.withOpacity(0.7),
                          child: ListTile(
                            title: Text(filteredItems[index]['name']),
                            subtitle: Text(
                              'Zakupione: ${filteredItems[index]['purchased']} | Pozostałe: ${filteredItems[index]['remaining']}',
                            ),
                            // Icon for editing each item
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.grey[800]),
                              onPressed: () {
                                // Action to edit the inventory item
                                // Replace this with your desired edit functionality
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Bottom Navigation
                BottomNavigation(
                  onTap: (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
