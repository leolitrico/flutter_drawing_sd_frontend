import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_drawing_board/models/undo_redo_manager.dart';
import 'package:flutter_drawing_board/pages/batch_page.dart';
import 'package:flutter_drawing_board/stable_api/drawing_to_img.dart';
import 'package:flutter_drawing_board/stable_api/drawing_to_inpainting.dart';
import 'package:flutter_drawing_board/stable_api/sketch_to_img.dart';
import 'package:flutter_drawing_board/stable_api/sketch_to_inpainting.dart';
import 'package:flutter_drawing_board/utils/create_mask.dart';
import 'package:flutter_drawing_board/utils/get_control_sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PromptBox extends HookWidget {
  final GlobalKey canvasGlobalKey;
  final double canvasWidth;
  final double canvasHeight;
  final ValueNotifier<UndoRedoManager> undoRedoManager;

  const PromptBox(
      {Key? key,
      required this.canvasGlobalKey,
      required this.canvasWidth,
      required this.canvasHeight,
      required this.undoRedoManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final text = useState('');
    final isTxt2ImgLoading = useState(false);
    final isImg2ImgLoading = useState(false);

    ////////////////////////////////////////////////////////////
    /// SKETCH SINGLE FUNCTION
    ////////////////////////////////////////////////////////////

    void sketchSingle() async {
      isTxt2ImgLoading.value = true;

      // get the control sketch
      final controlSketch = await getControlSketch(
          undoRedoManager.value.sketchesNotifier.value,
          canvasWidth,
          canvasHeight);

      // check if there is a background image
      final image = undoRedoManager.value.backgroundImageNotifier.value;
      if (image == null) {
        // do standard SD image generation
        try {
          final outputImage = await sketchToImageSingle(
              controlSketch: controlSketch, text: text.value);

          undoRedoManager.value.newBackgroundImage(outputImage);
        } catch (e) {
          print("Error: $e");
        }
      } else {
        // get the mask
        final mask = await createMask(
            undoRedoManager.value.sketchesNotifier.value,
            canvasWidth,
            canvasHeight);
        try {
          final outputImage = await sketchToInpaintingSingle(
              image: image,
              controlSketch: controlSketch,
              mask: mask,
              text: text.value);

          undoRedoManager.value.newBackgroundImage(outputImage);
        } catch (e) {
          print("Error: $e");
        }
      }

      isTxt2ImgLoading.value = false;
    }

    ////////////////////////////////////////////////////////////
    /// SKETCH BATCH FUNCTION
    ////////////////////////////////////////////////////////////

    void sketchBatch() async {
      isTxt2ImgLoading.value = true;

      // get the control sketch
      final controlSketch = await getControlSketch(
          undoRedoManager.value.sketchesNotifier.value,
          canvasWidth,
          canvasHeight);

      // check if there is a background image
      final image = undoRedoManager.value.backgroundImageNotifier.value;
      if (image == null) {
        // do standard SD image generation
        try {
          final outputImages = await sketchToImageBatch(
              controlSketch: controlSketch, text: text.value);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BatchPage(
                    undoRedoManager: undoRedoManager, images: outputImages)),
          );
        } catch (e) {
          print("Error: $e");
        }
      } else {
        // get the mask
        final mask = await createMask(
            undoRedoManager.value.sketchesNotifier.value,
            canvasWidth,
            canvasHeight);
        try {
          final outputImages = await sketchToInpaintingBatch(
              image: image,
              controlSketch: controlSketch,
              mask: mask,
              text: text.value);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BatchPage(
                    undoRedoManager: undoRedoManager, images: outputImages)),
          );
        } catch (e) {
          print("Error: $e");
        }
      }

      isTxt2ImgLoading.value = false;
    }

    ////////////////////////////////////////////////////////////
    /// DRAWING BATCH FUNCTION
    ////////////////////////////////////////////////////////////

    void drawingBatch() async {
      isImg2ImgLoading.value = true;
      // get the control sketch
      final controlSketch = await getControlSketch(
          undoRedoManager.value.sketchesNotifier.value,
          canvasWidth,
          canvasHeight);

      // check if there is a background image
      final image = undoRedoManager.value.backgroundImageNotifier.value;
      if (image == null) {
        // do standard SD image generation
        try {
          final outputImages =
              await drawingToImgBatch(image: controlSketch, text: text.value);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BatchPage(
                    undoRedoManager: undoRedoManager, images: outputImages)),
          );
        } catch (e) {
          print("Error: $e");
        }
      } else {
        // get the entire canvas as an image
        final canvasImage = await getCanvasImage();

        // get the mask
        final mask = await createMask(
            undoRedoManager.value.sketchesNotifier.value,
            canvasWidth,
            canvasHeight);
        try {
          final outputImages = await drawingInpaintingBatch(
              image: canvasImage,
              controlSketch: controlSketch,
              mask: mask,
              text: text.value);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BatchPage(
                    undoRedoManager: undoRedoManager, images: outputImages)),
          );
        } catch (e) {
          print("Error: $e");
        }
      }

      isImg2ImgLoading.value = false;
    }

    ////////////////////////////////////////////////////////////
    /// DRAWING SINGLE FUNCTION
    ////////////////////////////////////////////////////////////

    void drawingSingle() async {
      isImg2ImgLoading.value = true;
      // get the control sketch
      final controlSketch = await getControlSketch(
          undoRedoManager.value.sketchesNotifier.value,
          canvasWidth,
          canvasHeight);

      // check if there is a background image
      final image = undoRedoManager.value.backgroundImageNotifier.value;
      if (image == null) {
        // do standard SD image generation
        try {
          final outputImage =
              await drawingToImgSingle(image: controlSketch, text: text.value);

          undoRedoManager.value.newBackgroundImage(outputImage);
        } catch (e) {
          print("Error: $e");
        }
      } else {
        // get the entire canvas as an image
        final canvasImage = await getCanvasImage();

        // get the mask
        final mask = await createMask(
            undoRedoManager.value.sketchesNotifier.value,
            canvasWidth,
            canvasHeight);
        try {
          final outputImage = await drawingInpaintingSingle(
              image: canvasImage,
              controlSketch: controlSketch,
              mask: mask,
              text: text.value);

          undoRedoManager.value.newBackgroundImage(outputImage);
        } catch (e) {
          print("Error: $e");
        }
      }

      isImg2ImgLoading.value = false;
    }

    ////////////////////////////////////////////////////////////
    /// UI
    ////////////////////////////////////////////////////////////

    return Container(
      width: 600,
      height: 250,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("Sketch"),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  child: isTxt2ImgLoading.value
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                sketchSingle();
                              },
                              child: const Text('Single'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                sketchBatch();
                              },
                              child: const Text('Batch'),
                            ),
                          ],
                        ),
                ),
                const Spacer(),
                const Text("Painting"),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  child: isImg2ImgLoading.value
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                drawingSingle();
                              },
                              child: const Text('Single'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                drawingBatch();
                              },
                              child: const Text('Batch'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          )
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
