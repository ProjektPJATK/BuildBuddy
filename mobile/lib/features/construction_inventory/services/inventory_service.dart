import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import '../models/inventory_item_model.dart';

class InventoryService {
  // Pobieranie przedmiotów inwentarza
  Future<List<InventoryItemModel>> fetchInventoryItems(
      String token, int placeId) async {
    try {
      // Pobranie endpointu z konfiguracji
      final url = AppConfig.getInventoryEndpoint(placeId);

      final response = await http.get(
        Uri.parse(url),
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
