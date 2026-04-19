import 'package:uuid/uuid.dart';
import 'canvas_widget_model.dart';

/// Project model - har project ka complete data store karta hai
/// Ismein project ka naam, widgets ki list, aur metadata hain
class ProjectModel {
  final String id;
  String name;
  final DateTime createdAt;
  DateTime updatedAt;
  List<CanvasWidgetModel> widgets;
  double canvasWidth;
  double canvasHeight;

  ProjectModel({
    String? id,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CanvasWidgetModel>? widgets,
    this.canvasWidth = 412.0,  // Default Pixel 6 width
    this.canvasHeight = 915.0, // Default Pixel 6 height
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        widgets = widgets ?? [];

  /// Update timestamp jab koi change ho
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Add widget to project
  void addWidget(CanvasWidgetModel widget) {
    widgets.add(widget);
    touch();
  }

  /// Remove widget from project
  void removeWidget(String widgetId) {
    widgets.removeWhere((w) => w.id == widgetId);
    // Remove from parent's children list bhi
    for (var widget in widgets) {
      widget.childIds.remove(widgetId);
    }
    touch();
  }

  /// Get widget by ID
  CanvasWidgetModel? getWidget(String widgetId) {
    try {
      return widgets.firstWhere((w) => w.id == widgetId);
    } catch (_) {
      return null;
    }
  }

  /// Find parent of a widget
  CanvasWidgetModel? getParent(String widgetId) {
    final widget = getWidget(widgetId);
    if (widget?.parentId != null) {
      return getWidget(widget!.parentId!);
    }
    return null;
  }

  /// Reorder widgets (for z-index)
  void bringToFront(String widgetId) {
    final widget = getWidget(widgetId);
    if (widget != null) {
      widgets.remove(widget);
      widgets.add(widget);
      touch();
    }
  }

  /// Clone project with new ID
  ProjectModel duplicate() {
    final newWidgets = widgets.map((w) {
      return w.copyWith(id: Uuid().v4());
    }).toList();

    return ProjectModel(
      name: '$name (Copy)',
      widgets: newWidgets,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
    );
  }

  /// JSON serialization for saving
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'widgets': widgets.map((w) => w.toJson()).toList(),
      'canvasWidth': canvasWidth,
      'canvasHeight': canvasHeight,
    };
  }

  /// JSON deserialization for loading
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      widgets: (json['widgets'] as List?)
              ?.map((w) => CanvasWidgetModel.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      canvasWidth: (json['canvasWidth'] as num?)?.toDouble() ?? 412.0,
      canvasHeight: (json['canvasHeight'] as num?)?.toDouble() ?? 915.0,
    );
  }

  @override
  String toString() => 'ProjectModel(id: $id, name: $name, widgets: ${widgets.length})';
}
