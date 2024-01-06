import 'dart:ui';

import 'package:flutter_drawing_board/models/sketch.dart';
import 'package:flutter_drawing_board/utils/sketch_painter.dart';

Future<Image> mergeImageSketches(Image image, List<Sketch> sketches) async {
  // Create an image
  PictureRecorder recorder = PictureRecorder();
  Canvas canvas = Canvas(recorder);

  final width = image.width.toDouble();
  final height = image.height.toDouble();

  // init the painter and the size
  SketchPainter painter = SketchPainter(sketches: sketches);
  Size size = Size(width, height);

  // Paint on the canvas
  canvas.drawImage(image, Offset.zero, Paint());
  painter.paint(canvas, size);

  // Convert the image to bytes
  Picture picture = recorder.endRecording();
  Image img = await picture.toImage(width.toInt(), height.toInt());

  return img;
}
