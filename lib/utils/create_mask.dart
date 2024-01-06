import 'dart:ui';

import 'package:flutter_drawing_board/models/sketch.dart';

// ignore: constant_identifier_names
const PADDING = 2.0;

Future<Image> createMask(
    List<Sketch> sketches, double canvasWidth, double canvasHeight) async {
  // Calculate bounding box
  Rect boundingBox = _calculateBoundingBox(sketches);

  // Add padding to the bounding box
  boundingBox = boundingBox.inflate(PADDING);

  // Create an image
  PictureRecorder recorder = PictureRecorder();
  Canvas canvas = Canvas(recorder);

  // Draw the rectangle on the image
  Paint paint = Paint()
    ..color = const Color(0xFF808080); // White color for the rectangle
  canvas.drawRect(boundingBox, paint);

  // Convert the image to bytes
  Picture picture = recorder.endRecording();
  Image img = await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());

  return img;
}

Rect _calculateBoundingBox(List<Sketch> sketches) {
  double minX = double.infinity;
  double minY = double.infinity;
  double maxX = double.negativeInfinity;
  double maxY = double.negativeInfinity;

  // Find the minimum and maximum coordinates
  for (Sketch sketch in sketches) {
    for (Offset point in sketch.points) {
      minX = minX > point.dx ? point.dx : minX;
      minY = minY > point.dy ? point.dy : minY;
      maxX = maxX < point.dx ? point.dx : maxX;
      maxY = maxY < point.dy ? point.dy : maxY;
    }
  }

  // Create a bounding box
  return Rect.fromPoints(Offset(minX, minY), Offset(maxX, maxY));
}
