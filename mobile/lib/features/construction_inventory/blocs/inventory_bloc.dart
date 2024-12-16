import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/inventory_service.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryService inventoryService;

  InventoryBloc({required this.inventoryService}) : super(InventoryLoading()) {
    // Register event handlers
    on<LoadInventoryEvent>(_handleLoadInventoryEvent);
    on<FilterInventoryEvent>(_handleFilterInventoryEvent);
    on<UpdateInventoryItemEvent>(_handleUpdateInventoryItemEvent); // Register the handler here
  }

  Future<void> _handleLoadInventoryEvent(
      LoadInventoryEvent event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      final items = await inventoryService.fetchInventoryItems(
        event.token,
        event.placeId,
      );
      emit(InventoryLoaded(items: items, filteredItems: items));
    } catch (e) {
      emit(InventoryError('Failed to load inventory items: $e'));
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
          return item.copyWith(remaining: event.newRemaining);
        }
        return item;
      }).toList();
      emit(currentState.copyWith(items: updatedItems, filteredItems: updatedItems));
    }
  }
}
