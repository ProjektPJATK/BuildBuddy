abstract class InventoryEvent {}

class LoadInventoryEvent extends InventoryEvent {
  final String token;
  final int placeId;

  LoadInventoryEvent({required this.token, required this.placeId});
}

class FilterInventoryEvent extends InventoryEvent {
  final String query;

  FilterInventoryEvent({required this.query});
}

class UpdateInventoryItemEvent extends InventoryEvent {
  final int itemId;
  final int newRemaining;

  UpdateInventoryItemEvent({required this.itemId, required this.newRemaining});
}