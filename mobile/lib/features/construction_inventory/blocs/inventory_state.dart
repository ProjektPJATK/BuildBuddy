import 'package:mobile/features/construction_inventory/models/inventory_item_model.dart';

abstract class InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItemModel> items;
  final List<InventoryItemModel> filteredItems;

  InventoryLoaded({required this.items, required this.filteredItems});
}

class InventoryError extends InventoryState {
  final String message;

  InventoryError(this.message);
}
