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
        List<Map<String, dynamic>> tasks =
            jsonData.map<Map<String, dynamic>>((task) {
          return {
            'id': task['id'],
            'name': task['name'],
            'message': task['message'],
            'startTime': DateTime.parse(task['startTime']),
            'endTime': DateTime.parse(task['endTime']),
            'jobId': task['id'],
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

  // Create a new task actualization and return jobId instead of actualizationId
  static Future<int> createTaskActualization(int jobId, String message) async {
    final url = Uri.parse('${AppConfig.getBaseUrl()}/api/JobActualization');

    final body = jsonEncode({
      "id": 0,
      "message": message,
      "isDone": false,
      "jobImageUrl": [],
      "jobId": jobId,
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
      return jobId;
    } else {
      print('Failed to create task actualization.');
      throw Exception('Failed to create task actualization');
    }
  }

  // Upload images to the newly created actualization
  static Future<void> uploadImages(int jobId, List<File> images) async {
    print('Uploading ${images.length} images for Job ID: $jobId');

    List<String> uploadedPaths = [];

    for (File image in images) {
      int retries = 0;
      bool uploaded = false;

      while (!uploaded && retries < 3) {
        try {
          print('Attempting to upload image: ${image.path} (Try: ${retries + 1}/3)');
          final imagePath = await uploadImage(jobId, image);  // Get image path after upload
          uploadedPaths.add(imagePath);  // Store image paths
          print('Image uploaded successfully: ${image.path}');
          uploaded = true;
        } catch (e) {
          retries++;
          print('Failed to upload image: ${image.path}');
          if (retries == 3) {
            print('ERROR: Image upload failed after 3 attempts.');
            throw Exception('Failed to upload image: ${image.path}');
          }
        }
      }
    }
    print('All image paths uploaded: $uploadedPaths');
  }

  // Upload a single image to the correct endpoint using jobId
  static Future<String> uploadImage(int jobId, File image) async {
    final url = Uri.parse(AppConfig.postAddImageEndpoint(jobId));

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
      print('Image uploaded successfully for Job ID: $jobId');
      
      // Simulate returning the uploaded image path (extract from response or generate)
      return 'images/job/${image.path.split('/').last}';
    } else {
      print('Failed to upload image.');
      throw Exception('Failed to upload image');
    }
  }
}
