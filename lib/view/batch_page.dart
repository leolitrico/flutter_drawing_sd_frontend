import 'package:flutter/material.dart' hide Image;
import 'dart:ui';

class BatchPage extends StatefulWidget {
  final List<Image> images; // Change the type to ui.Image
  final ValueNotifier<Image?> backgroundImage;

  const BatchPage(
      {Key? key, required this.images, required this.backgroundImage})
      : super(key: key);

  @override
  _BatchPageState createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  int _selectedImageIndex = 0;

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
                  child: CustomPaint(
                    painter: ImagePainter(widget.images[index]),
                    child: Container(
                      alignment: Alignment.bottomRight,
                      child: _selectedImageIndex == index
                          ? const Icon(Icons.check_circle,
                              color: Colors.green, size: 24.0)
                          : Container(),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20.0),
          Text('Selected Image Index: $_selectedImageIndex'),
          ElevatedButton(
            onPressed: () {
              // Set the selected image as the background (implement your logic here)
              Image selectedImage = widget.images[_selectedImageIndex];
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                widget.backgroundImage.value = selectedImage;
              }
              print('Set as background: $selectedImage');
            },
            child: const Text('Set as Background'),
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
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
