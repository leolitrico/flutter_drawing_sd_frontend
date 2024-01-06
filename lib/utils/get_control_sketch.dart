import 'dart:ui';
import 'package:flutter_drawing_board/models/sketch.dart';
import 'package:flutter_drawing_board/utils/sketch_painter.dart';

Future<Image> getControlSketch(
    List<Sketch> sketches, double canvasWidth, double canvasHeight) async {
  // Create an image
  PictureRecorder recorder = PictureRecorder();
  Canvas canvas = Canvas(recorder);

  // init the painter and the size
  SketchPainter painter = SketchPainter(sketches: sketches);
  Size size = Size(canvasWidth, canvasHeight);

  // Paint on the canvas
  painter.paint(canvas, size);

  // Convert the image to bytes
  Picture picture = recorder.endRecording();
  Image img = await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());

  return img;
}
