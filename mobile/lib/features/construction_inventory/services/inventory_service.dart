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
}
