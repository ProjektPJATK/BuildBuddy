import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/construction_inventory/views/widgets/inventory_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/inventory_bloc.dart';
import '../blocs/inventory_event.dart';
import '../blocs/inventory_state.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/themes/styles.dart';
import '../../../shared/state/app_state.dart' as appState;

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
    appState.currentPage = 'construction_inventory';
    _loadInventory();
  }

  void _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final placeId = prefs.getInt('placeId');

    if (token != null && placeId != null) {
      context.read<InventoryBloc>().add(LoadInventoryEvent(token: token, placeId: placeId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error')),
      );
    }
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
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                child: Text(
                  'Inwentarz budowy',
                  style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    context.read<InventoryBloc>().add(FilterInventoryEvent(query: query));
                  },
                  decoration: InputDecoration(
                    hintText: 'Wyszukaj przedmioty...',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
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
                              context.read<InventoryBloc>().add(
                                    UpdateInventoryEvent(
                                      itemId: item.id,
                                      newRemaining: item.remaining - 1, // Przykład
                                    ),
                                  );
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No items available.'));
                    }
                  },
                ),
              ),
              BottomNavigation(onTap: (_) {}),
            ],
          ),
        ],
      ),
    );
  }
}
