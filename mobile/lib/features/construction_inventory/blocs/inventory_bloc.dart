import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/inventory_item_model.dart';
import '../services/inventory_service.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryService inventoryService;

  InventoryBloc({required this.inventoryService}) : super(InventoryLoading());

  @override
  Stream<InventoryState> mapEventToState(InventoryEvent event) async* {
    if (event is LoadInventoryEvent) {
      yield InventoryLoading();
      try {
        // Fetch inventory items using the service
        final items = await InventoryService.fetchInventoryItems(event.token, event.placeId);
        yield InventoryLoaded(items: items, filteredItems: items);
      } catch (e) {
        yield InventoryError('Failed to load inventory items');
      }
    } else if (event is UpdateInventoryEvent) {
      if (state is InventoryLoaded) {
        try {
          final currentState = state as InventoryLoaded;

          // Find the item to update
          final updatedItem = currentState.items.firstWhere((item) => item.id == event.itemId);

          // Create a new list of items with the updated item
          final updatedItems = List<InventoryItemModel>.from(currentState.items)
            ..[currentState.items.indexOf(updatedItem)] =
                updatedItem.copyWith(remaining: event.newRemaining);

          // Emit the updated state
          yield InventoryLoaded(items: updatedItems, filteredItems: updatedItems);
        } catch (e) {
          yield InventoryError('Failed to update item');
        }
      }
    } else if (event is FilterInventoryEvent) {
      if (state is InventoryLoaded) {
        final currentState = state as InventoryLoaded;

        // Filter the items based on the query
        final filteredItems = currentState.items.where((item) {
          return item.name.toLowerCase().contains(event.query.toLowerCase());
        }).toList();

        // Emit the updated state with filtered items
        yield InventoryLoaded(items: currentState.items, filteredItems: filteredItems);
      }
    }
  }
}
