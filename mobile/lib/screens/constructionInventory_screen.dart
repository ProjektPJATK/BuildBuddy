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
    int? placeId = prefs.getInt('placeId'); // Retrieve the placeId

    if (token == null || placeId == null) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5007/api/Item/place/$placeId'), // Fetch items by placeId
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
              'metrics': item['metrics'], // Include metrics field
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

  Future<void> _openEditDialog(Map<String, dynamic> item) async {
    TextEditingController remainingController = TextEditingController(text: item['remaining'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edytuj Pozostałe',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: remainingController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Pozostałe',
              hintStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                final int newRemaining = int.parse(remainingController.text);

                if (newRemaining > item['purchased']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pozostałe nie może być większe niż kupione!')),
                  );
                } else {
                  _updateItem(item['id'], newRemaining, item['name'], item['metrics']);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background for "Zapisz" button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Zapisz', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateItem(int itemId, int newRemaining, String name, String metrics) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? placeId = prefs.getInt('placeId'); // Retrieve the placeId

    if (token == null || placeId == null) return;

    final response = await http.put(
      Uri.parse('http://10.0.2.2:5007/api/Item/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': itemId,
        'name': name, // Include the required Name field
        'quantityMax': inventoryItems.firstWhere((item) => item['id'] == itemId)['purchased'],
        'metrics': metrics, // Include the required Metrics field
        'quantityLeft': newRemaining, // Only update the quantityLeft value
        'placeId': placeId, // Add the placeId field
      }),
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully')),
      );
      await _fetchInventoryItems(); // Refresh the inventory items after update
    } else {
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
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Container(
                  color: AppStyles.transparentWhite,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                  child: Text(
                    'Inwentarz budowy',
                    style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                  ),
                ),
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
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _isError
                            ? const Center(child: Text('Error fetching inventory items'))
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
