import 'dart:convert';
import 'dart:html'; // Use this for HttpRequest and localStorage
import 'package:web/config/config.dart';

class TaskService {
  // Filter tasks by selected day
  static List<Map<String, dynamic>> getTasksForDay(
      List<Map<String, dynamic>> tasks, DateTime day) {
    return tasks.where((task) {
      final start = task['startTime'] as DateTime;
      final end = task['endTime'] as DateTime;

      return day.isAfter(start.subtract(const Duration(days: 1))) &&
          day.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Fetch tasks for the logged-in user
  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final userId = _getFromLocalStorage('userId');
      if (userId == null) {
        throw Exception('User ID not found in local storage');
      }

      final url = AppConfig.getUserJobEndpoint(int.parse(userId));
      final response = await HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: {'Content-Type': 'application/json'},
      );

      if (response.status == 200) {
        List<dynamic> jsonData = json.decode(response.responseText!);
        List<Map<String, dynamic>> tasks =
            jsonData.map<Map<String, dynamic>>((task) {
          return {
            'id': task['id'],
            'name': task['name'],
            'message': task['message'],
            'startTime': DateTime.parse(task['startTime']),
            'endTime': DateTime.parse(task['endTime']),
            'jobId': task['id'], // Reflects the correct jobId
          };
        }).toList();

        print('Tasks successfully fetched: ${tasks.length}');
        return tasks;
      } else {
        print('Failed to load tasks. Status Code: ${response.status}');
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTasksByAddress(
      int userId, int addressId) async {
    try {
      print('Fetching tasks for userId: $userId and addressId: $addressId');

      final endpoint = AppConfig.getUserJobActualizationByAddress(userId, addressId);
      final response = await HttpRequest.request(
        endpoint,
        method: 'GET',
        requestHeaders: {'Content-Type': 'application/json'},
      );

      if (response.status != 200) {
        print('Failed to fetch tasks. Response Body: ${response.responseText}');
        throw Exception(
            'Failed to fetch tasks with status code: ${response.status}');
      }

      final List<dynamic> jsonData = json.decode(response.responseText!);
      print('Decoded JSON Data: $jsonData');

      final tasks = jsonData.map<Map<String, dynamic>>((task) {
        try {
          final startTime = DateTime.parse(task['startTime']?.toString() ?? '');
          final endTime = DateTime.parse(task['endTime']?.toString() ?? '');

          return {
            'id': int.tryParse(task['id']?.toString() ?? '') ?? 0,
            'addressId': int.tryParse(task['addressId']?.toString() ?? '') ?? 0,
            'name': task['name']?.toString() ?? 'Unknown',
            'message': task['message']?.toString() ?? '',
            'startTime': startTime, // Now parsed as DateTime
            'endTime': endTime, // Now parsed as DateTime
            'allDay': task['allDay'] ?? false,
          };
        } catch (parseError) {
          print('Error parsing task: $task, Error: $parseError');
          throw parseError;
        }
      }).toList();

      print('Mapped tasks: $tasks');
      return tasks;
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  // Utility: Fetch data from localStorage
  static String? _getFromLocalStorage(String key) {
    final value = window.localStorage[key];
    print('Fetching from localStorage: $key = $value');
    return value;
  }

  // Utility: Save data to localStorage
  static void _saveToLocalStorage(String key, String value) {
    print('Saving to localStorage: $key = $value');
    window.localStorage[key] = value;
  }

  // Create a new task actualization
  static Future<int> createTaskActualization(int jobId, String message) async {
    final url = AppConfig.postJobActualizationEndpoint();

    final body = jsonEncode({
      "id": 0,
      "message": message,
      "isDone": false,
      "jobImageUrl": [],
      "jobId": jobId, // Updated to use jobId
    });

    print('Creating task actualization for jobId: $jobId...');
    print('Request Body: $body');

    final response = await HttpRequest.request(
      url,
      method: 'POST',
      requestHeaders: {'Content-Type': 'application/json'},
      sendData: body,
    );

    if (response.status == 200 || response.status == 201) {
      final jsonResponse = json.decode(response.responseText!);
      print('Task Actualization created successfully. ID: ${jsonResponse['id']}');
      return jsonResponse['id'];
    } else {
      print('Failed to create task actualization.');
      throw Exception('Failed to create task actualization');
    }
  }
}
