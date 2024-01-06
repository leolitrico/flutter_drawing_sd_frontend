import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_drawing_board/models/sketch.dart';

///A data structure for undoing and redoing sketches.
class UndoRedoManager {
  UndoRedoManager(
      {required this.backgroundImageNotifier,
      required this.sketchesNotifier,
      required this.currentSketchNotifier}) {
    _sketchCount = sketchesNotifier.value.length;

    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<List<Sketch>> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;
  final ValueNotifier<Image?> backgroundImageNotifier;

  ///Collection of sketches that can be redone.
  final List<Sketch> _redoSketchStack = [];
  final List<Image> _redoBackgroundStack = [];
  final List<Image> _undoBackgroundStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  ///Whether an undo operation is possible
  ValueNotifier<bool> get canUndo => _canUndo;
  final ValueNotifier<bool> _canUndo = ValueNotifier(false);

  late int _sketchCount;

  void _updateCanUndo() {
    _canUndo.value = backgroundImageNotifier.value != null ||
        _undoBackgroundStack.isNotEmpty ||
        sketchesNotifier.value.isNotEmpty;
  }

  void _updateCanRedo() {
    _canRedo.value =
        _redoBackgroundStack.isNotEmpty || _redoSketchStack.isNotEmpty;
  }

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoSketchStack.clear();
      _redoBackgroundStack.clear();

      _sketchCount = sketchesNotifier.value.length;
    }
    _updateCanUndo();
    _updateCanRedo();
  }

  void clear() {
    _sketchCount = 0;

    // clear all redo and undo stacks
    _undoBackgroundStack.clear();
    _redoBackgroundStack.clear();
    _redoSketchStack.clear();

    // clear all values
    sketchesNotifier.value = [];
    backgroundImageNotifier.value = null;
    currentSketchNotifier.value = null;

    _updateCanUndo();
    _updateCanRedo();
  }

  void newBackgroundImage(Image image) {
    // clear all sketches
    sketchesNotifier.value.clear();
    currentSketchNotifier.value = null;

    // add the current background image to undo stack if it is not null
    final currentBackground = backgroundImageNotifier.value;
    if (currentBackground != null) {
      _undoBackgroundStack.add(currentBackground);
    }

    // update background to new image
    backgroundImageNotifier.value = image;

    _updateCanUndo();
    _updateCanRedo();
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoSketchStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      currentSketchNotifier.value = null;
    } else if (_undoBackgroundStack.isEmpty) {
      // add current background to redo stack if it not null
      if (backgroundImageNotifier.value != null) {
        _redoBackgroundStack.add(backgroundImageNotifier.value!);
      }

      // set background to null
      backgroundImageNotifier.value = null;
    } else {
      // add current image to the redo stack if it is not null
      if (backgroundImageNotifier.value != null) {
        _redoBackgroundStack.add(backgroundImageNotifier.value!);
      }

      // update background
      final newBackgroundImage = _undoBackgroundStack.removeLast();
      backgroundImageNotifier.value = newBackgroundImage;
    }

    _updateCanUndo();
    _updateCanRedo();
  }

  void redo() {
    if (sketchesNotifier.value.isEmpty && _redoBackgroundStack.isNotEmpty) {
      final currentBackground = backgroundImageNotifier.value;

      // add current image to undo stack if it is not null
      if (currentBackground != null) {
        _undoBackgroundStack.add(currentBackground);
      }

      // set background as last image added to redo stack
      final newBackground = _redoBackgroundStack.removeLast();
      backgroundImageNotifier.value = newBackground;
    } else if (_redoSketchStack.isNotEmpty) {
      final sketch = _redoSketchStack.removeLast();
      _sketchCount++;
      sketchesNotifier.value = [...sketchesNotifier.value, sketch];
    }

    _updateCanUndo();
    _updateCanRedo();
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
