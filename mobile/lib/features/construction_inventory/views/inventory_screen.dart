import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/construction_inventory/views/widgets/edit_item_dialog.dart';
import 'package:mobile/features/construction_inventory/views/widgets/inventory_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/inventory_bloc.dart';
import '../blocs/inventory_event.dart';
import '../blocs/inventory_state.dart';
import '../models/inventory_item_model.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/themes/styles.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  void _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final placeIdString = prefs.getString('placeId'); // Retrieve as String

    if (token != null && placeIdString != null) {
      final placeId = int.tryParse(placeIdString); // Convert to int
      if (placeId != null) {
        context.read<InventoryBloc>().add(
              LoadInventoryEvent(token: token, placeId: placeId),
            );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid place ID in cache')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load inventory: Missing data')),
      );
    }
  }

  void _showEditItemDialog(BuildContext context, InventoryItemModel item) {
  showDialog(
    context: context,
    builder: (context) {
      return EditItemDialog(
        remaining: item.remaining,
        purchased: item.purchased,
        onSave: (newRemaining) {
          print('New remaining quantity: $newRemaining');
          context.read<InventoryBloc>().add(
                UpdateInventoryItemEvent(
                  itemId: item.id,
                  newRemaining: newRemaining,
                ),
              );
        },
      );
    },
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
              Container(
                color: AppStyles.transparentWhite,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  'Inventory',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    context
                        .read<InventoryBloc>()
                        .add(FilterInventoryEvent(query: query));
                  },
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is InventoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is InventoryError) {
                      return Center(child: Text(state.message));
                    } else if (state is InventoryLoaded) {
                      return ListView.builder(
                        itemCount: state.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = state.filteredItems[index];
                          return InventoryItemCard(
                            name: item.name,
                            purchased: item.purchased,
                            remaining: item.remaining,
                            onEdit: () {
                              _showEditItemDialog(context, item);
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: Text('No items found.'));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/inventory');
          }
        },
      ),
    );
  }
}
