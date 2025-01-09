import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/construction_inventory/models/inventory_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/inventory_service.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryService inventoryService;

  InventoryBloc({required this.inventoryService}) : super(InventoryLoading()) {
    on<LoadInventoryEvent>(_handleLoadInventoryEvent);
    on<FilterInventoryEvent>(_handleFilterInventoryEvent);
    on<UpdateInventoryItemEvent>(_handleUpdateInventoryItemEvent);
  }

  Future<void> _handleLoadInventoryEvent(
      LoadInventoryEvent event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());

    // Spróbuj wczytać dane z cache
    final cachedItems = await _loadFromCache();
    if (cachedItems.isNotEmpty) {
      emit(InventoryLoaded(items: cachedItems, filteredItems: cachedItems));
    }

    // Ładowanie z backendu
    try {
      final items = await inventoryService.fetchInventoryItems(
        event.token,
        event.addressId,
      );

      // Zapis do cache
      await _saveToCache(items);

      emit(InventoryLoaded(items: items, filteredItems: items));
    } catch (e) {
      if (cachedItems.isEmpty) {
        emit(InventoryError('Failed to load inventory items: $e'));
      }
    }
  }

  void _handleFilterInventoryEvent(
      FilterInventoryEvent event, Emitter<InventoryState> emit) {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      final filteredItems = currentState.items
          .where((item) =>
              item.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(currentState.copyWith(filteredItems: filteredItems));
    }
  }

  void _handleUpdateInventoryItemEvent(
    UpdateInventoryItemEvent event, Emitter<InventoryState> emit) {
  if (state is InventoryLoaded) {
    final currentState = state as InventoryLoaded;
    final updatedItems = currentState.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(remaining: event.newRemaining); // Use double here
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: updatedItems, filteredItems: updatedItems));
  }
}


  // Zapis danych do cache
  Future<void> _saveToCache(List<InventoryItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString('inventory_cache', jsonData);
  }

  // Odczyt danych z cache
  Future<List<InventoryItemModel>> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('inventory_cache');

    if (cachedData != null) {
      final List<dynamic> decodedData = jsonDecode(cachedData);
      return decodedData
          .map((item) => InventoryItemModel.fromJson(item))
          .toList();
    }

    return [];
  }
}
