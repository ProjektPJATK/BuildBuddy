abstract class InventoryEvent {}

class LoadInventoryEvent extends InventoryEvent {
  final String token;
  final int placeId;

  LoadInventoryEvent({required this.token, required this.placeId});
}

class UpdateInventoryEvent extends InventoryEvent {
  final int itemId;
  final int newRemaining;

  UpdateInventoryEvent({required this.itemId, required this.newRemaining});
}

class FilterInventoryEvent extends InventoryEvent {
  final String query;

  FilterInventoryEvent({required this.query});
}
