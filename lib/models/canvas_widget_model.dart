import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'widget_type.dart';

/// Canvas pe draw kiye gaye har widget ka state
/// Har widget ki position, size, properties yahan store hain
class CanvasWidgetModel {
  final String id;
  final WidgetType type;
  Offset position;
  Size size;
  Map<String, dynamic> properties;
  String? parentId;
  List<String> childIds;
  double rotation;
  double scale;

  CanvasWidgetModel({
    String? id,
    required this.type,
    this.position = Offset.zero,
    this.size = const Size(100, 50),
    Map<String, dynamic>? properties,
    this.parentId,
    List<String>? childIds,
    this.rotation = 0.0,
    this.scale = 1.0,
  })  : id = id ?? Uuid().v4(),
        properties = properties ?? _getDefaultProperties(type),
        childIds = childIds ?? [];

  /// Default properties for each widget type - yahan se properties set hain
  static Map<String, dynamic> _getDefaultProperties(WidgetType type) {
    switch (type) {
      case WidgetType.text:
        return {
          'text': 'Sample Text',
          'fontSize': 16.0,
          'fontWeight': 'normal',
          'color': '#000000',
          'textAlign': 'left',
        };
      case WidgetType.icon:
        return {
          'iconName': 'Icons.star',
          'size': 24.0,
          'color': '#757575',
        };
      case WidgetType.image:
        return {
          'imageUrl': 'https://picsum.photos/200',
          'width': 100.0,
          'height': 100.0,
          'fit': 'cover',
        };
      case WidgetType.elevatedButton:
      case WidgetType.textButton:
      case WidgetType.outlinedButton:
        return {
          'label': 'Button',
          'buttonColor': '#6750A4',
          'textColor': '#FFFFFF',
        };
      case WidgetType.container:
      case WidgetType.containerDecorated:
        return {
          'width': 100.0,
          'height': 50.0,
          'color': '#E0E0E0',
          'borderRadius': 0.0,
          'borderColor': '#000000',
          'borderWidth': 0.0,
        };
      case WidgetType.card:
        return {
          'elevation': 2.0,
          'color': '#FFFFFF',
          'borderRadius': 12.0,
        };
      case WidgetType.iconButton:
        return {
          'iconName': 'Icons.add',
          'iconSize': 24.0,
          'color': '#757575',
        };
      case WidgetType.circleAvatar:
        return {
          'radius': 20.0,
          'backgroundColor': '#2196F3',
          'foregroundColor': '#FFFFFF',
          'text': 'A',
        };
      case WidgetType.chip:
        return {
          'label': 'Chip',
          'backgroundColor': '#E0E0E0',
          'deleteIcon': false,
        };
      case WidgetType.badge:
        return {
          'label': '1',
          'backgroundColor': '#F44336',
        };
      case WidgetType.linearProgressIndicator:
        return {
          'value': 0.5,
          'color': '#6750A4',
          'backgroundColor': '#E0E0E0',
        };
      case WidgetType.circularProgressIndicator:
        return {
          'size': 40.0,
          'color': '#6750A4',
        };
      case WidgetType.switchWidget:
        return {
          'value': false,
          'activeColor': '#6750A4',
        };
      case WidgetType.checkbox:
        return {
          'value': false,
          'activeColor': '#6750A4',
        };
      case WidgetType.appBar:
        return {
          'title': 'AppBar',
          'backgroundColor': '#6750A4',
          'elevation': 0.0,
          'centerTitle': false,
        };
      case WidgetType.listTile:
        return {
          'title': 'ListTile',
          'subtitle': '',
          'leadingIcon': 'Icons.list',
          'trailingIcon': 'Icons.arrow_forward_ios',
        };
      case WidgetType.divider:
        return {
          'thickness': 1.0,
          'color': '#E0E0E0',
        };
      case WidgetType.row:
      case WidgetType.column:
      case WidgetType.stack:
      case WidgetType.wrap:
        return {
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'start',
          'spacing': 8.0,
        };
      case WidgetType.padding:
        return {
          'padding': 16.0,
        };
      case WidgetType.center:
      case WidgetType.expanded:
      case WidgetType.flexible:
        return {};
      case WidgetType.scaffold:
        return {
          'backgroundColor': '#FFFFFF',
          'appBarTitle': 'Scaffold',
          'appBarColor': '#6750A4',
        };
      case WidgetType.radio:
        return {
          'value': 'a',
          'groupValue': null,
          'activeColor': '#6750A4',
        };
    }
  }

  /// Clone method for creating copies
  CanvasWidgetModel copyWith({
    String? id,
    WidgetType? type,
    Offset? position,
    Size? size,
    Map<String, dynamic>? properties,
    String? parentId,
    List<String>? childIds,
    double? rotation,
    double? scale,
  }) {
    return CanvasWidgetModel(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      properties: properties ?? Map<String, dynamic>.from(this.properties),
      parentId: parentId ?? this.parentId,
      childIds: childIds ?? List<String>.from(this.childIds),
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
    );
  }

  /// JSON serialization for saving
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'positionX': position.dx,
      'positionY': position.dy,
      'width': size.width,
      'height': size.height,
      'properties': properties,
      'parentId': parentId,
      'childIds': childIds,
      'rotation': rotation,
      'scale': scale,
    };
  }

  /// JSON deserialization for loading
  factory CanvasWidgetModel.fromJson(Map<String, dynamic> json) {
    return CanvasWidgetModel(
      id: json['id'] as String,
      type: WidgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WidgetType.container,
      ),
      position: Offset(
        (json['positionX'] as num?)?.toDouble() ?? 0.0,
        (json['positionY'] as num?)?.toDouble() ?? 0.0,
      ),
      size: Size(
        (json['width'] as num?)?.toDouble() ?? 100.0,
        (json['height'] as num?)?.toDouble() ?? 50.0,
      ),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      parentId: json['parentId'] as String?,
      childIds: List<String>.from(json['childIds'] ?? []),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  String toString() => 'CanvasWidgetModel(id: $id, type: ${type.name}, position: $position)';
}
