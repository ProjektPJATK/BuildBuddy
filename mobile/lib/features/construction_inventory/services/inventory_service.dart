import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import '../models/inventory_item_model.dart';

class InventoryService {
  // Fetch inventory items
  Future<List<InventoryItemModel>> fetchInventoryItems(
      String token, int addressId) async {
    try {
      final url = AppConfig.getInventoryEndpoint(addressId);
      print('[InventoryService] Fetching inventory from: $url');

      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('[InventoryService] Response status: ${response.statusCode}');

      // Log response body if status is not 200 for debugging
      if (response.statusCode != 200) {
        print('[InventoryService] Response body (Error): ${response.body}');
        throw Exception(
            '[InventoryService] Failed to fetch inventory items. Status: ${response.statusCode}');
      }

      // Decode the response and log
      print('[InventoryService] Response body (Success): ${response.body}');
      final List<dynamic> data = jsonDecode(response.body);

      // Map the data into models
      final items =
          data.map((item) => InventoryItemModel.fromJson(item)).toList();
      print(
          '[InventoryService] Successfully mapped ${items.length} inventory items.');
      return items;
    } catch (e) {
      // Log error
      print('[InventoryService] Error fetching inventory items: $e');
      throw Exception(
          '[InventoryService] Failed to fetch inventory items. Error: $e');
    }
  }

  // Update inventory item with all fields
  Future<void> updateInventoryItem(
      String token, int itemId, double newRemaining) async {
    final url = AppConfig.getUpdateInventoryEndpoint(itemId);
    print('[InventoryService] Updating inventory item at: $url');

    // Fetch the current item details first
    final currentItem = await fetchInventoryItemDetails(token, itemId);

    // Update only the `quantityLeft` field and retain other fields
    final body = jsonEncode({
      'id': currentItem.id,
      'name': currentItem.name,
      'metrics': currentItem.metrics,
      'quantityMax': currentItem.remaining,
      'quantityLeft': newRemaining, // Update only this field
      'addressId': currentItem.addressId,
    });

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('[InventoryService] Response status: ${response.statusCode}');
    print('[InventoryService] Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          '[InventoryService] Failed to update inventory item on the server. Status: ${response.statusCode}');
    }
  }

  // Fetch inventory item details (helper method)
  Future<InventoryItemModel> fetchInventoryItemDetails(
      String token, int itemId) async {
    final url = '${AppConfig.getBaseUrl()}/api/BuildingArticles/$itemId';
    print('[InventoryService] Fetching inventory item details from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200  ) {
      throw Exception(
          '[InventoryService] Failed to fetch inventory item details. Status: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return InventoryItemModel.fromJson(data);
  }
}
