import 'dart:convert';
import 'dart:html'; // For HttpRequest and localStorage
import 'package:web/config/config.dart';
import 'package:web/models/inventory_iem_model.dart';

class InventoryService {
  // Fetch inventory items
  Future<List<InventoryItemModel>> fetchInventoryItems(String token, int addressId) async {
    try {
      final url = AppConfig.getInventoryEndpoint(addressId);
      print('[InventoryService] Fetching inventory from: $url');

      final response = await HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.status == 200) {
        final List<dynamic> data = jsonDecode(response.responseText!);
        final items = data.map((item) => InventoryItemModel.fromJson(item)).toList();
        print('[InventoryService] Successfully fetched ${items.length} items.');
        return items;
      } else if (response.status == 404) {
        print('[InventoryService] No inventory items found.');
        return []; // Return an empty list when 404 is encountered
      } else {
        print('[InventoryService] Error: ${response.responseText}');
        throw Exception('Failed to fetch inventory items. Status: ${response.status}');
      }
    } catch (e) {
      print('[InventoryService] Error fetching inventory items: $e');
      return []; // Return an empty list on error to avoid crashing
    }
  }

 Future<void> updateInventoryItem(
    String token, int itemId, {
    String? name,
    double? purchased,
    String? metrics,
    double? remaining,
  }) async {
  final url = AppConfig.getUpdateInventoryEndpoint(itemId);
  print('[InventoryService] Updating inventory item at: $url');

  // Prepare the PATCH body for updating fields dynamically
  final List<Map<String, dynamic>> patchData = [];

  if (name != null) {
    patchData.add({'op': 'replace', 'path': '/name', 'value': name});
  }
  if (purchased != null) {
    patchData.add({'op': 'replace', 'path': '/quantityMax', 'value': purchased});
  }
  if (metrics != null) {
    patchData.add({'op': 'replace', 'path': '/metrics', 'value': metrics});
  }
  if (remaining != null) {
    patchData.add({'op': 'replace', 'path': '/quantityLeft', 'value': remaining});
  }

  if (patchData.isEmpty) {
    print('[InventoryService] No fields to update.');
    return;
  }

  try {
    final response = await HttpRequest.request(
      url,
      method: 'PATCH',
      requestHeaders: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json-patch+json',
      },
      sendData: jsonEncode(patchData),
    );

    print('[InventoryService] Response status: ${response.status}');
    print('[InventoryService] Response body: ${response.responseText}');

    if (response.status != 200 && response.status != 204) {
      throw Exception(
          '[InventoryService] Failed to update inventory item. Status: ${response.status}, Response: ${response.responseText}');
    }

    print('[InventoryService] Inventory item updated successfully.');
  } catch (e) {
    print('[InventoryService] Error updating inventory item: $e');

    // Provide detailed error information
    if (e is ProgressEvent) {
      final target = e.target as HttpRequest?;
      if (target != null) {
        print('[InventoryService] Network error details: '
            'Status: ${target.status}, Response: ${target.responseText}');
      }
    }

    throw Exception(
        '[InventoryService] Failed to update inventory item. Error: $e');
  }
}

  // Add a new building article
  Future<void> addBuildingArticle(String token, Map<String, dynamic> articleData) async {
    final url = AppConfig.postBuildingArticleEndpoint();
    print('[InventoryService] Adding new building article at: $url');

    try {
      final response = await HttpRequest.request(
        url,
        method: 'POST',
        requestHeaders: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        sendData: jsonEncode(articleData),
      );

      if (response.status == 200 || response.status == 201) {
        print('[InventoryService] Building article added successfully.');
      } else {
        print('[InventoryService] Error: ${response.responseText}');
        throw Exception('Failed to add building article. Status: ${response.status}');
      }
    } catch (e) {
      print('[InventoryService] Error adding building article: $e');
      throw Exception('Failed to add building article. Error: $e');
    }
  }

  // Delete a building article
  Future<void> deleteBuildingArticle(String token, int articleId) async {
    final url = AppConfig.deleteBuildingArticleEndpoint(articleId);
    print('[InventoryService] Deleting building article at: $url');

    try {
      final response = await HttpRequest.request(
        url,
        method: 'DELETE',
        requestHeaders: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.status == 200 || response.status == 204) {
        print('[InventoryService] Building article deleted successfully.');
      } else {
        print('[InventoryService] Error: ${response.responseText}');
        throw Exception('Failed to delete building article. Status: ${response.status}');
      }
    } catch (e) {
      print('[InventoryService] Error deleting building article: $e');
      throw Exception('Failed to delete building article. Error: $e');
    }
  }

  // Fetch addresses where the user is present
  static Future<List<Map<String, dynamic>>> getAddressesForUser(int userId) async {
    final url = AppConfig.getTeamsEndpoint(userId);
    print('[InventoryService] Fetching addresses for user: $url');

    try {
      final response = await HttpRequest.request(url, method: 'GET');

      if (response.status == 200) {
        final List<dynamic> data = jsonDecode(response.responseText!);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else if (response.status == 404) {
        print('[InventoryService] No addresses found for user.');
        return []; // Return an empty list when 404 is encountered
      } else {
        throw Exception('Failed to fetch addresses. Status: ${response.status}');
      }
    } catch (e) {
      print('[InventoryService] Error fetching addresses: $e');
      return []; // Return an empty list on error to avoid crashing
    }
  }

  
}
