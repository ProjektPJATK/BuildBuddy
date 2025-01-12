import 'dart:convert';
import 'dart:html'; // For HttpRequest and localStorage
import 'package:web/config/config.dart';

class TaskService {
  // Fetch tasks by address ID
  static Future<List<Map<String, dynamic>>> fetchTasksByAddress(int userId, int addressId) async {
    final url = AppConfig.getUserJobActualizationByAddress(userId, addressId);
    print('[TaskService] Fetching tasks by address ID: $url');

    try {
      final response = await HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: {'Content-Type': 'application/json'},
      );

      if (response.status == 200) {
        final List<dynamic> data = json.decode(response.responseText!);
        print('[TaskService] Tasks fetched successfully: ${data.length}');

        return data.map<Map<String, dynamic>>((task) {
          return {
            'id': task['id'],
            'name': task['name'],
            'message': task['message'],
            'startTime': DateTime.parse(task['startTime']),
            'endTime': DateTime.parse(task['endTime']),
            'allDay': task['allDay'],
            'addressId': task['addressId'],
          };
        }).toList();
      } else {
        print('[TaskService] Failed to fetch tasks. Status: ${response.status}');
        throw Exception('Failed to fetch tasks by address ID');
      }
    } catch (e) {
      print('[TaskService] Error fetching tasks: $e');
      rethrow;
    }
  }

  // Toggle job actualization status
  static Future<void> toggleJobActualizationStatus(int id) async {
    final url = AppConfig.toggleJobActualizationStatusEndpoint(id);
    print('[TaskService] Toggling status for job actualization ID: $id at $url');

    try {
      final response = await HttpRequest.request(
        url,
        method: 'POST',
        requestHeaders: {'Content-Type': 'application/json'},
      );

      if (response.status == 200) {
        print('[TaskService] Successfully toggled status for job actualization ID: $id');
      } else {
        print('[TaskService] Failed to toggle status. Status: ${response.status}');
        throw Exception('Failed to toggle job actualization status');
      }
    } catch (e) {
      print('[TaskService] Error toggling status: $e');
      rethrow;
    }
  }

  // Utility: Fetch data from localStorage
  static String? _getFromLocalStorage(String key) {
    final value = window.localStorage[key];
    print('[TaskService] Fetching from localStorage: $key = $value');
    return value;
  }

  // Utility: Save data to localStorage
  static void _saveToLocalStorage(String key, String value) {
    print('[TaskService] Saving to localStorage: $key = $value');
    window.localStorage[key] = value;
  }

  // Fetch all tasks for the logged-in user
  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final userId = _getFromLocalStorage('userId');
      if (userId == null) {
        throw Exception('[TaskService] User ID not found in local storage');
      }

      final url = AppConfig.getUserJobEndpoint(int.parse(userId));
      print('[TaskService] Fetching tasks for user ID: $userId from $url');

      final response = await HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: {'Content-Type': 'application/json'},
      );

      if (response.status == 200) {
        final List<dynamic> jsonData = json.decode(response.responseText!);
        print('[TaskService] Tasks fetched successfully: ${jsonData.length}');

        return jsonData.map<Map<String, dynamic>>((task) {
          return {
            'id': task['id'],
            'name': task['name'],
            'message': task['message'],
            'startTime': DateTime.parse(task['startTime']),
            'endTime': DateTime.parse(task['endTime']),
            'jobId': task['id'],
          };
        }).toList();
      } else {
        print('[TaskService] Failed to fetch tasks. Status: ${response.status}');
        throw Exception('Failed to fetch tasks for user ID');
      }
    } catch (e) {
      print('[TaskService] Error fetching tasks: $e');
      rethrow;
    }
  }

  // Create a new task actualization
  static Future<int> createTaskActualization(int jobId, String message) async {
    final url = AppConfig.postJobActualizationEndpoint();
    print('[TaskService] Creating task actualization at $url');

    final body = jsonEncode({
      "id": 0,
      "message": message,
      "isDone": false,
      "jobImageUrl": [],
      "jobId": jobId,
    });

    try {
      final response = await HttpRequest.request(
        url,
        method: 'POST',
        requestHeaders: {'Content-Type': 'application/json'},
        sendData: body,
      );

      if (response.status == 200 || response.status == 201) {
        final jsonResponse = json.decode(response.responseText!);
        print('[TaskService] Task actualization created successfully. ID: ${jsonResponse['id']}');
        return jsonResponse['id'];
      } else {
        print('[TaskService] Failed to create task actualization. Status: ${response.status}');
        throw Exception('Failed to create task actualization');
      }
    } catch (e) {
      print('[TaskService] Error creating task actualization: $e');
      rethrow;
    }
  }
}
