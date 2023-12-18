import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter_drawing_board/view/drawing_canvas/stable_api/api_endpoint.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/utils/image_encoder.dart';
import 'package:http/http.dart' as http;

const API_IMG_2_IMG_ENDPOINT = "sdapi/v1/txt2img";

Future<ui.Image> drawingToImgSingle({
  required ui.Image image,
  required String text,
}) async {
  try {
    final apiUrl = Uri.parse(API_ENDPOINT + API_IMG_2_IMG_ENDPOINT);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final encodedImage = encodeImageToBase64(image);

    // compute the output width and height
    final imageSizeRatio = image.height / image.width;
    const outputWidth = 512;
    final outputHeight = imageSizeRatio * outputWidth;

    final Map<String, dynamic> requestBody = {
      "prompt": text,
      "batch_size": 1,
      "steps": 20,
      "width": outputWidth,
      "height": outputHeight,
      "cfg_scale": 7,
      "sampler_index": "Euler a",
      //"hr_sampler_name": "Euler a",
      "alwayson_scripts": {
        "controlnet": {
          "args": [
            {
              "input_image": encodedImage,
              "module": "scribble_hed",
              "model": "control_sd15_scribble [fef5e48e]",
              //"model": "control_sd15_canny [fef5e48e]",
              "control_mode": 0,
              "pixel_perfect": true,
              "resize_mode": 1,
              "processor_res": 512,
              "guidance_end": 1.0
            }
          ]
        }
      }
    };

    final String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      apiUrl,
      headers: headers,
      body: requestBodyJson,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final encodedImage = data['images'][0];

      final image = await decodeImageFromBase64(encodedImage);
      return image;
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<List<ui.Image>> drawingToImgBatch({
  required ui.Image image,
  required String text,
}) async {
  try {
    final apiUrl = Uri.parse(API_ENDPOINT + API_IMG_2_IMG_ENDPOINT);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final encodedImage = encodeImageToBase64(image);

    // compute the output width and height
    final imageSizeRatio = image.height / image.width;
    const outputWidth = 256;
    final outputHeight = imageSizeRatio * outputWidth;

    final Map<String, dynamic> requestBody = {
      "prompt": text,
      "batch_size": 6,
      "steps": 20,
      "width": outputWidth,
      "height": outputHeight,
      "cfg_scale": 7,
      "sampler_index": "Euler a",
      //"hr_sampler_name": "Euler a",
      "alwayson_scripts": {
        "controlnet": {
          "args": [
            {
              "input_image": encodedImage,
              "module": "scribble_hed",
              "model": "control_sd15_scribble [fef5e48e]",
              //"model": "control_sd15_canny [fef5e48e]",
              "control_mode": 0,
              "pixel_perfect": true,
              "resize_mode": 1,
              "processor_res": 512,
              "guidance_end": 1.0
            }
          ]
        }
      }
    };

    final String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      apiUrl,
      headers: headers,
      body: requestBodyJson,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<ui.Image> images = [];

      List<dynamic> imageList =
          data['images']; // Assuming 'images' is a List<dynamic>

      for (var item in imageList) {
        if (item is String) {
          ui.Image image = await decodeImageFromBase64(item);
          images.add(image);
        }
      }

      return images;
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
