import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_drawing_board/main.dart';
import 'package:flutter_drawing_board/models/undo_redo_manager.dart';
import 'package:flutter_drawing_board/models/sketch.dart';
import 'package:flutter_drawing_board/pages/drawing_page/widgets/drawing_canvas.dart';
import 'package:flutter_drawing_board/models/drawing_mode.dart';
import 'package:flutter_drawing_board/pages/drawing_page/widgets/canvas_side_bar.dart';
import 'package:flutter_drawing_board/pages/drawing_page/widgets/prompt_box.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingPage extends HookWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final allSketches = useState<List<Sketch>>([]);
    final currentSketch = useState<Sketch?>(null);
    final backgroundImage = useState<Image?>(null);
    final undoRedoManager = useState<UndoRedoManager>(UndoRedoManager(
        backgroundImageNotifier: backgroundImage,
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch));

    final toolsAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    final canvasGlobalKey = GlobalKey();

    final canvasHeight = MediaQuery.of(context).size.height;
    final canvasWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: kCanvasColor,
            width: double.maxFinite,
            height: double.maxFinite,
            child: DrawingCanvas(
              width: canvasWidth,
              height: canvasHeight,
              drawingMode: drawingMode,
              selectedColor: selectedColor,
              strokeSize: strokeSize,
              eraserSize: eraserSize,
              sideBarController: toolsAnimationController,
              canvasGlobalKey: canvasGlobalKey,
              filled: filled,
              polygonSides: polygonSides,
              allSketches: allSketches,
              currentSketch: currentSketch,
              backgroundImage: backgroundImage,
            ),
          ),
          Positioned(
            top: kToolbarHeight + 10,
            // left: -5,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(toolsAnimationController),
              child: CanvasSideBar(
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                strokeSize: strokeSize,
                eraserSize: eraserSize,
                canvasGlobalKey: canvasGlobalKey,
                filled: filled,
                polygonSides: polygonSides,
                undoRedoManager: undoRedoManager,
              ),
            ),
          ),
          _CustomAppBar(animationController: toolsAnimationController),
          Positioned(
              bottom: 0,
              right: 10,
              child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1), // Slide from the bottom
                    end: Offset.zero,
                  ).animate(toolsAnimationController),
                  child: PromptBox(
                      canvasGlobalKey: canvasGlobalKey,
                      canvasWidth: canvasWidth,
                      canvasHeight: canvasHeight,
                      undoRedoManager: undoRedoManager)))
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;

  const _CustomAppBar({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (animationController.value == 0) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
              icon: const Icon(Icons.menu),
            ),
            const Text(
              'SketchAI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
