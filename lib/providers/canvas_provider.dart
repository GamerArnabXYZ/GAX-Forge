import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Canvas state management - selected widget, transformations, undo/redo
/// Yeh provider canvas pe saare actions handle karta hai

/// Canvas state class - complete canvas ka state
class CanvasState {
  final List<CanvasWidgetModel> widgets;
  final String? selectedWidgetId;
  final List<List<CanvasWidgetModel>> undoStack;
  final List<List<CanvasWidgetModel>> redoStack;
  final double zoom;
  final Offset panOffset;
  final bool showGrid;
  final bool showRulers;

  const CanvasState({
    this.widgets = const [],
    this.selectedWidgetId,
    this.undoStack = const [],
    this.redoStack = const [],
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.showGrid = true,
    this.showRulers = false,
  });

  CanvasState copyWith({
    List<CanvasWidgetModel>? widgets,
    String? selectedWidgetId,
    bool clearSelection = false,
    List<List<CanvasWidgetModel>>? undoStack,
    List<List<CanvasWidgetModel>>? redoStack,
    double? zoom,
    Offset? panOffset,
    bool? showGrid,
    bool? showRulers,
  }) {
    return CanvasState(
      widgets: widgets ?? this.widgets,
      selectedWidgetId: clearSelection ? null : (selectedWidgetId ?? this.selectedWidgetId),
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
      showGrid: showGrid ?? this.showGrid,
      showRulers: showRulers ?? this.showRulers,
    );
  }

  /// Get selected widget
  CanvasWidgetModel? get selectedWidget {
    if (selectedWidgetId == null) return null;
    try {
      return widgets.firstWhere((w) => w.id == selectedWidgetId);
    } catch (_) {
      return null;
    }
  }

  /// Check if can undo
  bool get canUndo => undoStack.isNotEmpty;

  /// Check if can redo
  bool get canRedo => redoStack.isNotEmpty;
}

/// Canvas notifier - state management for canvas operations
class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(const CanvasState());

  /// Initialize canvas with project widgets
  void initializeFromProject(ProjectModel project) {
    state = CanvasState(widgets: List.from(project.widgets));
  }

  /// Clear canvas and reset state
  void clearCanvas() {
    state = const CanvasState();
  }

  /// Save current state to undo stack before making changes
  void _saveToUndoStack() {
    final newUndoStack = List<List<CanvasWidgetModel>>.from(state.undoStack);
    newUndoStack.add(List<CanvasWidgetModel>.from(state.widgets));

    // Limit undo stack to 50 items
    if (newUndoStack.length > 50) {
      newUndoStack.removeAt(0);
    }

    state = state.copyWith(
      undoStack: newUndoStack,
      redoStack: [], // Clear redo stack on new action
    );
  }

  /// Add widget to canvas
  void addWidget(CanvasWidgetModel widget) {
    _saveToUndoStack();
    state = state.copyWith(
      widgets: [...state.widgets, widget],
      selectedWidgetId: widget.id,
    );
  }

  /// Remove widget from canvas
  void removeWidget(String widgetId) {
    _saveToUndoStack();
    final newWidgets = state.widgets.where((w) => w.id != widgetId).toList();

    // Also remove from any parent's childIds
    for (var widget in newWidgets) {
      widget.childIds.remove(widgetId);
    }

    state = state.copyWith(
      widgets: newWidgets,
      clearSelection: state.selectedWidgetId == widgetId,
    );
  }

  /// Select a widget
  void selectWidget(String? widgetId) {
    state = state.copyWith(selectedWidgetId: widgetId);
  }

  /// Update widget position
  void updateWidgetPosition(String widgetId, Offset newPosition) {
    final widgetIndex = state.widgets.indexWhere((w) => w.id == widgetId);
    if (widgetIndex < 0) return;

    final widget = state.widgets[widgetIndex];
    state.widgets[widgetIndex] = widget.copyWith(position: newPosition);
    state = state.copyWith(widgets: List.from(state.widgets));
  }

  /// Update widget size (for resize gestures)
  void updateWidgetSize(String widgetId, Size newSize) {
    _saveToUndoStack();
    final widgetIndex = state.widgets.indexWhere((w) => w.id == widgetId);
    if (widgetIndex < 0) return;

    final widget = state.widgets[widgetIndex];
    state.widgets[widgetIndex] = widget.copyWith(
      size: Size(
        newSize.width.clamp(20, 2000),
        newSize.height.clamp(20, 2000),
      ),
    );
    state = state.copyWith(widgets: List.from(state.widgets));
  }

  /// Update widget properties
  void updateWidgetProperty(String widgetId, String propertyKey, dynamic value) {
    final widgetIndex = state.widgets.indexWhere((w) => w.id == widgetId);
    if (widgetIndex < 0) return;

    final widget = state.widgets[widgetIndex];
    final newProperties = Map<String, dynamic>.from(widget.properties);
    newProperties[propertyKey] = value;

    state.widgets[widgetIndex] = widget.copyWith(properties: newProperties);
    state = state.copyWith(widgets: List.from(state.widgets));
  }

  /// Update widget transform (scale, rotation)
  void updateWidgetTransform(String widgetId, {double? scale, double? rotation}) {
    final widgetIndex = state.widgets.indexWhere((w) => w.id == widgetId);
    if (widgetIndex < 0) return;

    final widget = state.widgets[widgetIndex];
    state.widgets[widgetIndex] = widget.copyWith(
      scale: scale ?? widget.scale,
      rotation: rotation ?? widget.rotation,
    );
    state = state.copyWith(widgets: List.from(state.widgets));
  }

  /// Commit transform change to undo stack
  void commitTransformChange() {
    _saveToUndoStack();
  }

  /// Duplicate selected widget
  void duplicateWidget(String widgetId) {
    _saveToUndoStack();
    final widgetIndex = state.widgets.indexWhere((w) => w.id == widgetId);
    if (widgetIndex < 0) return;

    final widget = state.widgets[widgetIndex];
    final duplicate = widget.copyWith(
      id: null, // New ID will be generated
      position: Offset(widget.position.dx + 20, widget.position.dy + 20),
    );

    state = state.copyWith(
      widgets: [...state.widgets, duplicate],
      selectedWidgetId: duplicate.id,
    );
  }

  /// Bring widget to front (z-index)
  void bringToFront(String widgetId) {
    _saveToUndoStack();
    final widget = state.widgets.firstWhere((w) => w.id == widgetId);
    final newWidgets = state.widgets.where((w) => w.id != widgetId).toList();
    newWidgets.add(widget);

    state = state.copyWith(widgets: newWidgets);
  }

  /// Send widget to back
  void sendToBack(String widgetId) {
    _saveToUndoStack();
    final widget = state.widgets.firstWhere((w) => w.id == widgetId);
    final newWidgets = state.widgets.where((w) => w.id != widgetId).toList();
    newWidgets.insert(0, widget);

    state = state.copyWith(widgets: newWidgets);
  }

  /// Undo last action
  void undo() {
    if (!state.canUndo) return;

    final newUndoStack = List<List<CanvasWidgetModel>>.from(state.undoStack);
    final previousState = newUndoStack.removeLast();

    final newRedoStack = List<List<CanvasWidgetModel>>.from(state.redoStack);
    newRedoStack.add(List<CanvasWidgetModel>.from(state.widgets));

    state = state.copyWith(
      widgets: previousState,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
      clearSelection: true,
    );
  }

  /// Redo previously undone action
  void redo() {
    if (!state.canRedo) return;

    final newRedoStack = List<List<CanvasWidgetModel>>.from(state.redoStack);
    final nextState = newRedoStack.removeLast();

    final newUndoStack = List<List<CanvasWidgetModel>>.from(state.undoStack);
    newUndoStack.add(List<CanvasWidgetModel>.from(state.widgets));

    state = state.copyWith(
      widgets: nextState,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
      clearSelection: true,
    );
  }

  /// Update zoom level
  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.25, 3.0));
  }

  /// Update pan offset
  void setPanOffset(Offset offset) {
    state = state.copyWith(panOffset: offset);
  }

  /// Toggle grid visibility
  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  /// Toggle rulers visibility
  void toggleRulers() {
    state = state.copyWith(showRulers: !state.showRulers);
  }

  /// Set parent-child relationship
  void setParent(String childId, String? parentId) {
    _saveToUndoStack();

    // Remove from old parent
    for (var widget in state.widgets) {
      if (widget.childIds.contains(childId)) {
        widget.childIds.remove(childId);
      }
    }

    // Set new parent
    if (parentId != null) {
      final parentIndex = state.widgets.indexWhere((w) => w.id == parentId);
      if (parentIndex >= 0) {
        final parent = state.widgets[parentIndex];
        if (!parent.childIds.contains(childId)) {
          parent.childIds.add(childId);
        }
      }

      final childIndex = state.widgets.indexWhere((w) => w.id == childId);
      if (childIndex >= 0) {
        state.widgets[childIndex] = state.widgets[childIndex].copyWith(parentId: parentId);
      }
    }

    state = state.copyWith(widgets: List.from(state.widgets));
  }
}

/// Canvas state provider
final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  return CanvasNotifier();
});

/// Provider for selected widget
final selectedWidgetProvider = Provider<CanvasWidgetModel?>((ref) {
  return ref.watch(canvasProvider).selectedWidget;
});

/// Provider for undo availability
final canUndoProvider = Provider<bool>((ref) {
  return ref.watch(canvasProvider).canUndo;
});

/// Provider for redo availability
final canRedoProvider = Provider<bool>((ref) {
  return ref.watch(canvasProvider).canRedo;
});
