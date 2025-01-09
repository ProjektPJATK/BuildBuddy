import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

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
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse(AppConfig.getUserJobEndpoint(userId)),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Map<String, dynamic>> tasks = jsonData.map<Map<String, dynamic>>((task) {
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
        print('Failed to load tasks. Status Code: ${response.statusCode}');
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  // Fetch job actualizations by jobId
  static Future<List<Map<String, dynamic>>> fetchJobActualizations(int jobId) async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.getJobActualizationEndpoint(jobId)), // Updated to use jobId
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map<Map<String, dynamic>>((actualization) {
          return {
            'id': actualization['id'],
            'message': actualization['message'],
            'isDone': actualization['isDone'],
            'jobImageUrl': List<String>.from(actualization['jobImageUrl'] ?? []),
          };
        }).toList();
      } else {
        print('Failed to fetch job actualizations. Status Code: ${response.statusCode}');
        throw Exception('Failed to fetch job actualizations');
      }
    } catch (e) {
      print('Error fetching job actualizations: $e');
      rethrow;
    }
  }

  // Create a new task actualization
  static Future<int> createTaskActualization(int jobId, String message) async {
    final url = Uri.parse(AppConfig.postJobActualizationEndpoint());

    final body = jsonEncode({
      "id": 0,
      "message": message,
      "isDone": false,
      "jobImageUrl": [],
      "jobId": jobId, // Updated to use jobId
    });

    print('Creating task actualization for jobId: $jobId...');
    print('Request Body: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      print('Task Actualization created successfully. ID: ${jsonResponse['id']}');
      return jsonResponse['id'];
    } else {
      print('Failed to create task actualization.');
      throw Exception('Failed to create task actualization');
    }
  }

  // Upload images to the actualization using jobActualizationId
  static Future<void> uploadImages(int jobActualizationId, List<File> images) async {
    print('Uploading ${images.length} images for JobActualization ID: $jobActualizationId');

    for (File image in images) {
      try {
        await uploadImage(jobActualizationId, image);
        print('Image uploaded successfully: ${image.path}');
      } catch (e) {
        print('Failed to upload image: ${image.path}');
        throw Exception('Failed to upload image: ${image.path}');
      }
    }
  }

  // Upload a single image to the correct endpoint using jobActualizationId
  static Future<String> uploadImage(int jobActualizationId, File image) async {
    final url = Uri.parse(AppConfig.postAddImageEndpoint(jobActualizationId));

    var request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    print('Sending image to URL: $url');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      print('Image uploaded successfully for JobActualization ID: $jobActualizationId');
      return 'images/job/${image.path.split('/').last}'; // Return image path
    } else {
      print('Failed to upload image.');
      throw Exception('Failed to upload image');
    }
  }
}
