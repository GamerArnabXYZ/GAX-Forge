// lib/providers/project_provider.dart
// GAX Forge - Riverpod State Management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_models.dart';

// ─────────────────────────────────────────────
// HIVE BOX PROVIDER
// ─────────────────────────────────────────────
final projectBoxProvider = Provider<Box<GaxProject>>((ref) {
  return Hive.box<GaxProject>('projects');
});

// ─────────────────────────────────────────────
// PROJECTS LIST PROVIDER
// ─────────────────────────────────────────────
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<GaxProject>>((ref) {
  final box = ref.watch(projectBoxProvider);
  return ProjectsNotifier(box);
});

class ProjectsNotifier extends StateNotifier<List<GaxProject>> {
  final Box<GaxProject> _box;

  ProjectsNotifier(this._box) : super(_box.values.toList().reversed.toList());

  void _sync() {
    state = _box.values.toList().reversed.toList();
  }

  Future<void> addProject(GaxProject project) async {
    await _box.put(project.id, project);
    _sync();
  }

  Future<void> updateProject(GaxProject project) async {
    // FIX: Directly save the passed project (not empty copyWith)
    await _box.put(project.id, project);
    _sync();
  }

  Future<void> deleteProject(String projectId) async {
    await _box.delete(projectId);
    _sync();
  }

  GaxProject? getProject(String id) {
    return _box.get(id);
  }
}

// ─────────────────────────────────────────────
// EDITOR STATE MODEL
// ─────────────────────────────────────────────
class EditorState {
  final GaxProject project;
  final int activeScreenIndex;
  final String? selectedWidgetId;
  final bool canvasLocked;
  final bool previewMode;
  final List<List<WidgetProperty>> undoStack;
  final List<List<WidgetProperty>> redoStack;
  final int activeTab; // 0=Widgets, 1=Canvas, 2=Preview
  final bool showAllWidgets;

  const EditorState({
    required this.project,
    this.activeScreenIndex = 0,
    this.selectedWidgetId,
    this.canvasLocked = false,
    this.previewMode = false,
    this.undoStack = const [],
    this.redoStack = const [],
    this.activeTab = 1,
    this.showAllWidgets = true,
  });

  CanvasScreen get activeScreen => project.screens[activeScreenIndex];

  List<WidgetProperty> get activeWidgets => activeScreen.widgets;

  WidgetProperty? get selectedWidget {
    if (selectedWidgetId == null) return null;
    try {
      return activeWidgets.firstWhere((w) => w.id == selectedWidgetId);
    } catch (_) {
      return null;
    }
  }

  EditorState copyWith({
    GaxProject? project,
    int? activeScreenIndex,
    String? Function()? selectedWidgetId,
    bool? canvasLocked,
    bool? previewMode,
    List<List<WidgetProperty>>? undoStack,
    List<List<WidgetProperty>>? redoStack,
    int? activeTab,
    bool? showAllWidgets,
  }) {
    return EditorState(
      project: project ?? this.project,
      activeScreenIndex: activeScreenIndex ?? this.activeScreenIndex,
      selectedWidgetId:
          selectedWidgetId != null ? selectedWidgetId() : this.selectedWidgetId,
      canvasLocked: canvasLocked ?? this.canvasLocked,
      previewMode: previewMode ?? this.previewMode,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      activeTab: activeTab ?? this.activeTab,
      showAllWidgets: showAllWidgets ?? this.showAllWidgets,
    );
  }
}

// ─────────────────────────────────────────────
// EDITOR STATE NOTIFIER
// ─────────────────────────────────────────────
final editorProvider =
    StateNotifierProvider.family<EditorNotifier, EditorState, String>(
        (ref, projectId) {
  final box = ref.watch(projectBoxProvider);
  final project = box.get(projectId)!;
  return EditorNotifier(project, ref);
});

class EditorNotifier extends StateNotifier<EditorState> {
  final Ref _ref;

  EditorNotifier(GaxProject project, this._ref)
      : super(EditorState(project: project));

  // ── Screen Management ──────────────────────
  void switchScreen(int index) {
    state = state.copyWith(
      activeScreenIndex: index,
      selectedWidgetId: () => null,
    );
  }

  void addScreen() {
    final screens = List<CanvasScreen>.from(state.project.screens);
    screens.add(CanvasScreen(name: 'Screen ${screens.length + 1}'));
    final updated = state.project.copyWith(screens: screens);
    state = state.copyWith(
      project: updated,
      activeScreenIndex: screens.length - 1,
    );
  }

  void renameScreen(int index, String name) {
    final screens = List<CanvasScreen>.from(state.project.screens);
    final old = screens[index];
    screens[index] = CanvasScreen(
      id: old.id,
      name: name,
      widgets: old.widgets,
      backgroundColor: old.backgroundColor,
    );
    state = state.copyWith(project: state.project.copyWith(screens: screens));
  }

  void reorderScreens(List<CanvasScreen> reordered) {
    state = state.copyWith(
      project: state.project.copyWith(screens: reordered),
      activeScreenIndex: 0,
    );
  }

  void setScreenSize(int index, String sizeId) {
    final screens = List<CanvasScreen>.from(state.project.screens);
    screens[index] = screens[index].copyWith(screenSize: sizeId);
    state = state.copyWith(project: state.project.copyWith(screens: screens));
  }

  void deleteScreen(int index) {
    if (state.project.screens.length <= 1) return;
    final screens = List<CanvasScreen>.from(state.project.screens)
      ..removeAt(index);
    final newIndex = (index >= screens.length) ? screens.length - 1 : index;
    state = state.copyWith(
      project: state.project.copyWith(screens: screens),
      activeScreenIndex: newIndex,
    );
  }

  // ── Widget Management ──────────────────────
  void _pushUndo() {
    final stack = List<List<WidgetProperty>>.from(state.undoStack);
    stack.add(List.from(state.activeWidgets));
    if (stack.length > 30) stack.removeAt(0);
    state = state.copyWith(undoStack: stack, redoStack: []);
  }

  void addWidget(String type) {
    _pushUndo();
    final widgets = List<WidgetProperty>.from(state.activeWidgets);
    final newWidget = WidgetProperty(
      type: type,
      x: 40.0 + (widgets.length * 8).toDouble(),
      y: 60.0 + (widgets.length * 8).toDouble(),
      zIndex: widgets.length,
    );
    widgets.add(newWidget);
    _updateActiveScreenWidgets(widgets);
    state = state.copyWith(selectedWidgetId: () => newWidget.id);
  }

  void moveWidget(String id, double dx, double dy) {
    final widgets = state.activeWidgets.map((w) {
      if (w.id == id) return w.copyWith(x: w.x + dx, y: w.y + dy);
      return w;
    }).toList();
    _updateActiveScreenWidgets(widgets);
  }

  void resizeWidget(String id, double width, double height) {
    // No _pushUndo here intentionally — resize is continuous,
    // push undo only on pan start (handled in UI)
    final widgets = state.activeWidgets.map((w) {
      if (w.id == id) {
        return w.copyWith(
          width: width.clamp(40, 800),
          height: height.clamp(20, 800),
        );
      }
      return w;
    }).toList();
    _updateActiveScreenWidgets(widgets);
  }

  void pushUndoForResize() => _pushUndo();

  void selectWidget(String? id) {
    state = state.copyWith(selectedWidgetId: () => id);
  }

  void updateWidgetProp(String id, String key, dynamic value) {
    _pushUndo();
    final widgets = state.activeWidgets.map((w) {
      if (w.id == id) {
        final props = Map<String, dynamic>.from(w.props);
        props[key] = value;
        return w.copyWith(props: props);
      }
      return w;
    }).toList();
    _updateActiveScreenWidgets(widgets);
  }

  void deleteWidget(String id) {
    _pushUndo();
    final widgets =
        state.activeWidgets.where((w) => w.id != id).toList();
    _updateActiveScreenWidgets(widgets);
    state = state.copyWith(selectedWidgetId: () => null);
  }

  void duplicateWidget(String id) {
    _pushUndo();
    final source = state.activeWidgets.firstWhere((w) => w.id == id);
    final duplicate = WidgetProperty(
      type: source.type,
      x: source.x + 20,
      y: source.y + 20,
      width: source.width,
      height: source.height,
      props: Map.from(source.props),
      zIndex: state.activeWidgets.length,
    );
    final widgets = [...state.activeWidgets, duplicate];
    _updateActiveScreenWidgets(widgets);
    state = state.copyWith(selectedWidgetId: () => duplicate.id);
  }

  void bringToFront(String id) {
    _pushUndo();
    final widgets = state.activeWidgets.map((w) {
      if (w.id == id) return w.copyWith(zIndex: state.activeWidgets.length);
      return w;
    }).toList();
    _updateActiveScreenWidgets(widgets);
  }

  void setCanvasBackground(int color) {
    final screens = List<CanvasScreen>.from(state.project.screens);
    final active = screens[state.activeScreenIndex];
    screens[state.activeScreenIndex] = CanvasScreen(
      id: active.id,
      name: active.name,
      widgets: active.widgets,
      backgroundColor: color,
    );
    state = state.copyWith(project: state.project.copyWith(screens: screens));
  }

  void _updateActiveScreenWidgets(List<WidgetProperty> widgets) {
    final screens = List<CanvasScreen>.from(state.project.screens);
    final active = screens[state.activeScreenIndex];
    screens[state.activeScreenIndex] = CanvasScreen(
      id: active.id,
      name: active.name,
      widgets: widgets,
      backgroundColor: active.backgroundColor,
    );
    state = state.copyWith(project: state.project.copyWith(screens: screens));
  }

  void sendToBack(String id) {
    _pushUndo();
    final widgets = state.activeWidgets.map((w) {
      if (w.id == id) return w.copyWith(zIndex: 0);
      return w.copyWith(zIndex: w.zIndex + 1);
    }).toList();
    _updateActiveScreenWidgets(widgets);
  }

  // ── Undo / Redo ───────────────────────────
  void undo() {
    if (state.undoStack.isEmpty) return;
    final undoStack = List<List<WidgetProperty>>.from(state.undoStack);
    final redoStack = List<List<WidgetProperty>>.from(state.redoStack);
    redoStack.add(List.from(state.activeWidgets));
    final previous = undoStack.removeLast();
    state = state.copyWith(undoStack: undoStack, redoStack: redoStack);
    _updateActiveScreenWidgets(previous);
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final undoStack = List<List<WidgetProperty>>.from(state.undoStack);
    final redoStack = List<List<WidgetProperty>>.from(state.redoStack);
    undoStack.add(List.from(state.activeWidgets));
    final next = redoStack.removeLast();
    state = state.copyWith(undoStack: undoStack, redoStack: redoStack);
    _updateActiveScreenWidgets(next);
  }

  // ── Canvas Controls ───────────────────────
  void toggleLock() {
    final nowLocked = !state.canvasLocked;
    state = state.copyWith(
      canvasLocked: nowLocked,
      selectedWidgetId: nowLocked ? null : () => null,
    );
  }

  void setTab(int tab) {
    final preview = tab == 2;
    state = state.copyWith(
      activeTab: tab,
      previewMode: preview,
      selectedWidgetId: preview ? () => null : null,
    );
  }

  void toggleWidgetFilter() {
    state = state.copyWith(showAllWidgets: !state.showAllWidgets);
  }

  // ── Save ──────────────────────────────────
  Future<void> save() async {
    await _ref
        .read(projectsProvider.notifier)
        .updateProject(state.project);
  }
}
