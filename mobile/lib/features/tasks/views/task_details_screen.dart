import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import '../../../shared/themes/styles.dart';
import 'widgets/task_update_dialog.dart';
import '../../../shared/config/config.dart';

class TaskDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String taskDate;
  final int taskId;

  const TaskDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.taskDate,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  List<String> imageUrls = [];
  String message = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTaskActualization();
  }

  // Fetch task actualization details and images
  Future<void> _fetchTaskActualization() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.getJobActualizationEndpoint(widget.taskId)),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          message = jsonData['message'] ?? '';
          imageUrls = List<String>.from(jsonData['jobImageUrl'] ?? []);
          isLoading = false;
        });
      } else {
        print('Failed to fetch actualization. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching task actualization: $e');
    }
  }

  void _showTaskUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => TaskUpdateDialog(
        jobId: widget.taskId,
        onSave: (comment, images) {
          print('Task Updated - ID: ${widget.taskId}');
          print('Komentarz: $comment');
          print('Zdjęcia: ${images.map((img) => img.path).toList()}');
          _fetchTaskActualization();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 16),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppStyles.transparentWhite,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: AppStyles.formTitleStyle),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.description, 'Opis', widget.description),
                          _buildDetailRow(Icons.timer, 'Rozpoczęcie', widget.startTime),
                          _buildDetailRow(Icons.timer_off, 'Zakończenie', widget.endTime),
                          _buildDetailRow(Icons.event, 'Data', widget.taskDate),

                          // Display message if available
                          if (message.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildDetailRow(Icons.message, 'Komentarz', message),
                          ],

                          // Display images in carousel if available
                          if (imageUrls.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildDisplayImageCarousel(imageUrls),
                          ],

                          const SizedBox(height: 30),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () => _showTaskUpdateDialog(context),
                              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                              label: const Text('Dodaj Aktualizację'),
                              style: AppStyles.buttonStyle(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$title: $content',
              style: AppStyles.textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

// Carousel for displaying images from the API
Widget _buildDisplayImageCarousel(List<String> urls) {
  return CarouselSlider(
    options: CarouselOptions(
      height: 200,
      enableInfiniteScroll: false,
      enlargeCenterPage: true,
    ),
    items: urls.map((url) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(url),  // Trigger full-screen view on tap
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://buildbuddybucket.s3.amazonaws.com/$url',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 100, color: Colors.white54),
                );
              },
            ),
          ),
        ),
      );
    }).toList(),
  );
}

void _showFullScreenImage(String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),  // 10% padding on each side
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),  // Close on tap
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Image.network(
              'https://buildbuddybucket.s3.amazonaws.com/$imageUrl',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 150, color: Colors.white54),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}


}
