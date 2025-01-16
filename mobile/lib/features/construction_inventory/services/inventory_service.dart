import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/features/construction_inventory/models/inventory_item_model.dart';
import 'package:mobile/shared/config/config.dart';

class InventoryService {
  // Fetch inventory items
  Future<List<InventoryItemModel>> fetchInventoryItems(
      String token, int addressId) async {
    try {
      final url = AppConfig.getInventoryEndpoint(addressId);
      print('[InventoryService] Fetching inventory from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('[InventoryService] Response status: ${response.statusCode}');
      if (response.statusCode == 404) {
        print('[InventoryService] No items found for the specified address.');
        return []; // Return an empty list for no items found
      }

      if (response.statusCode != 200) {
        print('[InventoryService] Response body (Error): ${response.body}');
        throw Exception(
            '[InventoryService] Failed to fetch inventory items. Status: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      final items = data.map((item) => InventoryItemModel.fromJson(item)).toList();
      print('[InventoryService] Successfully fetched ${items.length} items.');
      return items;
    } catch (e) {
      print('[InventoryService] Error fetching inventory items: $e');
      throw Exception(
          '[InventoryService] Failed to fetch inventory items. Error: $e');
    }
  }
  // Direct PATCH request to update a single field
  Future<void> updateInventoryItem(
      String token, int itemId, double newRemaining) async {
    final url = AppConfig.getUpdateInventoryEndpoint(itemId);
    print('[InventoryService] Updating inventory item at: $url');

    // Create PATCH body for updating only the `quantityLeft` field
    final body = jsonEncode([
      {
        'op': 'replace',       // Specify the operation
        'path': '/quantityLeft', // Path to the field being updated
        'value': newRemaining  // New value for the field
      }
    ]);

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json-patch+json',
        },
        body: body,
      );

      print('[InventoryService] Response status: ${response.statusCode}');
      print('[InventoryService] Response body: ${response.body}');

      // Check for success codes
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            '[InventoryService] Failed to update inventory item. Status: ${response.statusCode}');
      }

      print('[InventoryService] Inventory item updated successfully.');
    } catch (e) {
      print('[InventoryService] Error updating inventory item: $e');
      throw Exception(
          '[InventoryService] Failed to update inventory item. Error: $e');
    }
  }
}
