import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import '../models/inventory_item_model.dart';

class InventoryService {
  // Fetch inventory items
  Future<List<InventoryItemModel>> fetchInventoryItems(
      String token, int placeId) async {
    try {
    final url = AppConfig.getInventoryEndpoint(placeId);
    print('Fetching inventory from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => InventoryItemModel.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to fetch inventory items. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching inventory items: $e');
    throw Exception('Failed to fetch inventory items. Error: $e');
  }
}
}