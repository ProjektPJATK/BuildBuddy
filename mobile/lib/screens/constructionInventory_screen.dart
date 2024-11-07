import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> inventoryItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool _isLoading = true;
  bool _isError = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    appState.currentPage = 'construction_inventory';
    _fetchInventoryItems();
  }

  Future<void> _fetchInventoryItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5007/api/Item'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          inventoryItems = data.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'purchased': item['quantityMax'],
              'remaining': item['quantityLeft'],
            };
          }).toList();
          filteredItems = inventoryItems;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  void _filterInventory(String query) {
    final results = inventoryItems
        .where((item) => item['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredItems = results;
    });
  }

  // Open a dialog to edit "Pozostałe" value
  Future<void> _openEditDialog(Map<String, dynamic> item) async {
    TextEditingController remainingController = TextEditingController(text: item['remaining'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edytuj Pozostałe'),
          content: TextField(
            controller: remainingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pozostałe',
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Anuluj',
                style: TextStyle(color: Colors.lightBlue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Zapisz',
                style: TextStyle(color: Colors.lightBlue),
              ),
              onPressed: () {
                final int newRemaining = int.parse(remainingController.text);
                final int purchased = item['purchased'];

                // Validate if remaining value is less than or equal to purchased value
                if (newRemaining > purchased) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pozostałe nie może być większe niż kupione!')),
                  );
                } else {
                  _updateItem(item['id'], newRemaining); // Update the item
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Update the item on the server
  Future<void> _updateItem(int itemId, int newRemaining) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return;

    final response = await http.put(
      Uri.parse('http://10.0.2.2:5007/api/Item/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': itemId, // Ensure all necessary fields are included
        'name': inventoryItems.firstWhere((item) => item['id'] == itemId)['name'],
        'quantityMax': inventoryItems.firstWhere((item) => item['id'] == itemId)['purchased'],
        'metrics': 'some metrics', // Replace with actual metrics field
        'quantityLeft': newRemaining, // Update this field with the new remaining value
      }),
    );

    // Log the response to debug errors
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully')),
      );
      await _fetchInventoryItems(); // Re-fetch the inventory items automatically to refresh the UI
    } else {
      // Show the error message received from the server
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: ${response.body}')),
      );
    }
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
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                  child: Text(
                    'Inwentarz budowy',
                    style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                  ),
                ),
                // Search bar with background
                Container(
                  color: AppStyles.transparentWhite,
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
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                // Inventory list or loading/error state
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                        : _isError
                            ? const Center(child: Text('Error fetching inventory items')) // Show error message
                            : ListView.builder(
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
                                      trailing: IconButton(
                                        icon: Icon(Icons.edit, color: Colors.grey[800]),
                                        onPressed: () {
                                          _openEditDialog(filteredItems[index]);
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
