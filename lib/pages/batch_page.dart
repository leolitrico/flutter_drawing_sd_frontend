import 'package:flutter/material.dart' hide Image;
import 'dart:ui';

import 'package:flutter_drawing_board/models/undo_redo_manager.dart';

class BatchPage extends StatefulWidget {
  final List<Image> images; // Change the type to ui.Image
  final ValueNotifier<UndoRedoManager> undoRedoManager;

  const BatchPage({
    Key? key,
    required this.images,
    required this.undoRedoManager,
  }) : super(key: key);

  @override
  _BatchPageState createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  int? _selectedImageIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Adjust the number of columns as needed
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: widget.images.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedImageIndex == index
                            ? Colors.blue
                            : Colors.transparent,
                        width: 6.0,
                      ),
                    ),
                    child: CustomPaint(
                      painter: ImagePainter(widget.images[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              // Set the selected image as the background (implement your logic here)
              if (_selectedImageIndex != null) {
                Image selectedImage = widget.images[_selectedImageIndex!];
                if (Navigator.canPop(context)) {
                  widget.undoRedoManager.value
                      .newBackgroundImage(selectedImage);
                  Navigator.pop(context);
                }
              }
            },
            child: _selectedImageIndex != null
                ? const Text('Confirm')
                : const Text('Select An Image'),
          ),
        ],
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  final Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Adjust the destination rectangle to fill the available space
    final Rect destinationRect =
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height));

    canvas.drawImageRect(
      image,
      Rect.fromPoints(
          Offset.zero, Offset(image.width.toDouble(), image.height.toDouble())),
      destinationRect,
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
