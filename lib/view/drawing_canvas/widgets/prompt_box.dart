import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_drawing_board/view/batch_page.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/stable_api/drawing_to_img.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/stable_api/sketch_to_img.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;

final IP = "172.20.10.6";

class PromptBox extends HookWidget {
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<ui.Image?> backgroundImage;

  const PromptBox({
    Key? key,
    required this.canvasGlobalKey,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final text = useState('');
    final isTxt2ImgLoading = useState(false);
    final isImg2ImgLoading = useState(false);

    void sketchSingle() async {
      // get the canvas as an image
      final canvasImage = await getCanvasImage();

      // get the output from the api
      try {
        final newBackground =
            await sketchToImageSingle(image: canvasImage, text: text.value);

        // set the image as the new background
        backgroundImage.value = newBackground;
      } catch (e) {
        print("Error: $e");
      }
    }

    void sketchBatch() async {
      // get the canvas as an image
      final canvasImage = await getCanvasImage();

      // get the output from the api
      try {
        final batch =
            await sketchToImageBatch(image: canvasImage, text: text.value);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BatchPage(backgroundImage: backgroundImage, images: batch)),
        );
      } catch (e) {
        print("Error: $e");
      }
    }

    void drawingSingle() async {
      // get the canvas as an image
      final canvasImage = await getCanvasImage();

      // get the output from the api
      try {
        final newBackground =
            await drawingToImgSingle(image: canvasImage, text: text.value);

        // set the image as the new background
        backgroundImage.value = newBackground;
      } catch (e) {
        print("Error: $e");
      }
    }

    void drawingBatch() async {
      // get the canvas as an image
      final canvasImage = await getCanvasImage();

      // get the output from the api
      try {
        final batch =
            await drawingToImgBatch(image: canvasImage, text: text.value);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BatchPage(backgroundImage: backgroundImage, images: batch)),
        );
      } catch (e) {
        print("Error: $e");
      }
    }

    return Container(
      width: 600,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: textController,
                    onChanged: (value) => text.value = value,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Enter text prompt',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 150,
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: isImg2ImgLoading.value || isTxt2ImgLoading.value
                        ? null
                        : () => sketchSingle,
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isTxt2ImgLoading.value)
                            const CircularProgressIndicator()
                          else
                            const Text("txt2img")
                        ],
                      ),
                    )),
              ),
              Container(
                width: 150,
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: isImg2ImgLoading.value || isTxt2ImgLoading.value
                      ? null
                      : () => drawingSingle,
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isImg2ImgLoading.value)
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: const CircularProgressIndicator(),
                        )
                      else
                        const Text('img2img'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<ui.Image> getCanvasImage() async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;

    return await boundary.toImage();
  }
}
