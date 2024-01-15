import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter_drawing_board/stable_api/api_endpoint.dart';
import 'package:flutter_drawing_board/stable_api/change_model.dart';
import 'package:flutter_drawing_board/stable_api/models.dart';
import 'package:flutter_drawing_board/utils/image_encoder.dart';
import 'package:http/http.dart' as http;

// ignore: constant_identifier_names
const API_IMG_2_IMG_ENDPOINT = "sdapi/v1/img2img";

////////////////////////////////////////////////////////////////////////////////
/// SINGLE FUNCTION
////////////////////////////////////////////////////////////////////////////////

Future<ui.Image> drawingInpaintingSingle({
  required ui.Image image,
  required ui.Image controlSketch,
  required ui.Image mask,
  required String text,
}) async {
  await changeSDModel(INPAINTING_MODEL);

  try {
    final apiUrl = Uri.parse(API_ENDPOINT + API_IMG_2_IMG_ENDPOINT);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final encodedImage = await encodeImageToBase64(image);
    final encodedMask = await encodeImageToBase64(mask);
    final encodedControlSketch = await encodeImageToBase64(controlSketch);

    // compute the output width and height
    final imageSizeRatio = image.height / image.width;
    const outputWidth = 512;
    final outputHeight = imageSizeRatio * outputWidth;

    final Map<String, dynamic> requestBody = {
      "init_images": [encodedImage],
      "prompt": text,
      "batch_size": 1,
      "steps": 25,
      "width": outputWidth,
      "height": outputHeight,
      "cfg_scale": 7,
      "sampler_index": "Euler a",

      //inpainting
      "mask": encodedMask,
      "mask_blur": 4,
      "inpainting_fill": 1,
      "inpaint_full_res": 0,
      "inpaint_full_res_padding": 32,
      "inpainting_mask_invert": 0,
      "denoising_strength": 0.75,
      "include_init_images": false,
      "resize_mode": 0,

      // controlnet
      "alwayson_scripts": {
        "controlnet": {
          "args": [
            {
              "input_image": encodedControlSketch,
              "module": "scribble_hed",
              "model": "control_sd15_scribble [fef5e48e]",
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

////////////////////////////////////////////////////////////////////////////////
/// BATCH FUNCTION
////////////////////////////////////////////////////////////////////////////////

Future<List<ui.Image>> drawingInpaintingBatch({
  required ui.Image image,
  required ui.Image controlSketch,
  required ui.Image mask,
  required String text,
}) async {
  await changeSDModel(INPAINTING_MODEL);

  try {
    final apiUrl = Uri.parse(API_ENDPOINT + API_IMG_2_IMG_ENDPOINT);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final encodedImage = await encodeImageToBase64(image);
    final encodedMask = await encodeImageToBase64(mask);
    final encodedControlSketch = await encodeImageToBase64(controlSketch);

    // compute the output width and height
    final imageSizeRatio = image.height / image.width;
    const outputWidth = 512;
    final outputHeight = imageSizeRatio * outputWidth;

    final Map<String, dynamic> requestBody = {
      "init_images": [encodedImage],
      "prompt": text,
      "batch_size": 6,
      "steps": 25,
      "width": outputWidth,
      "height": outputHeight,
      "cfg_scale": 7,
      "sampler_index": "Euler a",

      //inpainting
      "mask": encodedMask,
      "mask_blur": 4,
      "inpainting_fill": 1,
      "inpaint_full_res": 0,
      "inpaint_full_res_padding": 32,
      "inpainting_mask_invert": 0,
      "denoising_strength": 0.75,
      "include_init_images": false,
      "resize_mode": 0,

      // controlnet
      "alwayson_scripts": {
        "controlnet": {
          "args": [
            {
              "input_image": encodedControlSketch,
              "module": "scribble_hed",
              "model": "control_sd15_scribble [fef5e48e]",
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

      // remove control net image
      imageList = imageList.sublist(0, imageList.length - 1);
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