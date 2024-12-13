import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_item_model.dart';

class InventoryService {
  final String _baseUrl = "http://10.0.2.2:5159/api";

  Future<List<InventoryItemModel>> fetchInventoryItems(
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
      } else {
        throw Exception(
            'Failed to fetch inventory items. Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch inventory items. Error: $e');
    }
  }
}
