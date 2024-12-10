import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_item_model.dart';

class InventoryService {
  static const String _baseUrl = "http://10.0.2.2:5007/api";

  /// Fetch inventory items for a specific place
  static Future<List<InventoryItemModel>> fetchInventoryItems(
      String token, int placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Item/place/$placeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => InventoryItemModel.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please check your credentials.');
      } else {
        throw Exception(
            'Failed to fetch inventory items. Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch inventory items. Error: $e');
    }
  }

  /// Update inventory item
  static Future<void> updateInventoryItem(
      String token, InventoryItemModel item, int placeId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Item/${item.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          ...item.toJson(),
          'placeId': placeId, // Ensure placeId is included in the request
        }),
      );

      if (response.statusCode != 204) {
        if (response.statusCode == 400) {
          throw Exception('Bad request. Please check the provided data.');
        } else if (response.statusCode == 401) {
          throw Exception('Unauthorized. Please check your credentials.');
        } else {
          throw Exception(
              'Failed to update inventory item. Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Failed to update inventory item. Error: $e');
    }
  }
}
