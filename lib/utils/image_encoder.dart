import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

// Function to encode a ui.Image to String
Future<String> encodeImageToBase64(ui.Image image) async {
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List? pngBytes = byteData?.buffer.asUint8List();

  // encode to base64
  return base64Encode(pngBytes ?? []);
}

// Function to decode an image from String to ui.Image
Future<ui.Image> decodeImageFromBase64(String base64String) async {
  final imageBytes = base64Decode(base64String);
  return await decodeImageFromList(imageBytes);
}
