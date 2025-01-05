import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<File> images;
  final Function(int) onRemoveImage;

  const ImageCarousel({
    super.key,
    required this.images,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
      ),
      items: images.asMap().entries.map((entry) {
        int index = entry.key;
        File image = entry.value;

        // Log the image path for debugging
        print('Displaying Image: ${image.path}');
        print('Image Exists: ${image.existsSync()}');

        return Stack(
          children: [
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: Image.file(image, fit: BoxFit.cover),
                ),
              ),
              child: Image.file(image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('Failed to load image'));
              }),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  print('Removing image at index: $index');
                  onRemoveImage(index);
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
