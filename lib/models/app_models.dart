// lib/models/app_models.dart
// GAX Forge - Core Data Models with Hive persistence

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

part 'app_models.g.dart';

const _uuid = Uuid();

// ─────────────────────────────────────────────
// WIDGET PROPERTY MODEL
// ─────────────────────────────────────────────
@HiveType(typeId: 0)
class WidgetProperty extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'Container','Text','Button', etc.

  @HiveField(2)
  double x;

  @HiveField(3)
  double y;

  @HiveField(4)
  double width;

  @HiveField(5)
  double height;

  @HiveField(6)
  Map<String, dynamic> props; // color, text, padding, margin, etc.

  @HiveField(7)
  int zIndex;

  WidgetProperty({
    String? id,
    required this.type,
    this.x = 0,
    this.y = 0,
    this.width = 120,
    this.height = 60,
    Map<String, dynamic>? props,
    this.zIndex = 0,
  })  : id = id ?? _uuid.v4(),
        props = props ?? _defaultProps(type);

  static Map<String, dynamic> _defaultProps(String type) {
    switch (type) {
      case 'Text':
        return {
          'text': 'Text Widget',
          'fontSize': 16.0,
          'fontWeight': 'normal',
          'color': 0xFF000000,
          'textAlign': 'left',
        };
      case 'Container':
        return {
          'color': 0xFF2196F3,
          'borderRadius': 8.0,
          'padding': 8.0,
          'margin': 0.0,
          'opacity': 1.0,
          'hasBorder': false,
          'borderColor': 0xFF000000,
          'borderWidth': 1.0,
        };
      case 'ElevatedButton':
        return {
          'text': 'Button',
          'color': 0xFF6750A4,
          'textColor': 0xFFFFFFFF,
          'borderRadius': 12.0,
          'fontSize': 14.0,
        };
      case 'OutlinedButton':
        return {
          'text': 'Outlined',
          'color': 0xFF6750A4,
          'borderRadius': 12.0,
          'fontSize': 14.0,
        };
      case 'TextButton':
        return {
          'text': 'Text Button',
          'color': 0xFF6750A4,
          'fontSize': 14.0,
        };
      case 'Card':
        return {
          'color': 0xFFFFFFFF,
          'elevation': 4.0,
          'borderRadius': 12.0,
        };
      case 'TextField':
        return {
          'hintText': 'Enter text...',
          'labelText': 'Label',
          'color': 0xFF6750A4,
          'borderRadius': 8.0,
        };
      case 'Icon':
        return {
          'iconCode': 0xe318, // Icons.star codepoint
          'color': 0xFF6750A4,
          'size': 32.0,
        };
      case 'CircleAvatar':
        return {
          'color': 0xFF6750A4,
          'radius': 30.0,
          'text': 'A',
          'textColor': 0xFFFFFFFF,
        };
      case 'Switch':
        return {'value': true, 'activeColor': 0xFF6750A4};
      case 'Checkbox':
        return {'value': true, 'activeColor': 0xFF6750A4};
      case 'Slider':
        return {
          'value': 0.5,
          'min': 0.0,
          'max': 1.0,
          'activeColor': 0xFF6750A4,
        };
      case 'LinearProgressIndicator':
        return {'value': 0.6, 'color': 0xFF6750A4, 'backgroundColor': 0xFFE8DEF8};
      case 'CircularProgressIndicator':
        return {'color': 0xFF6750A4};
      case 'Divider':
        return {'color': 0xFFCAC4D0, 'thickness': 1.0};
      case 'Chip':
        return {
          'label': 'Chip',
          'color': 0xFFE8DEF8,
          'textColor': 0xFF6750A4,
        };
      case 'Badge':
        return {
          'label': '9+',
          'color': 0xFFB3261E,
          'textColor': 0xFFFFFFFF,
          'childText': 'Badge',
        };
      case 'FloatingActionButton':
        return {
          'iconCode': 0xe145, // Icons.add
          'color': 0xFF6750A4,
          'iconColor': 0xFFFFFFFF,
          'mini': false,
        };
      case 'ListTile':
        return {
          'title': 'List Item',
          'subtitle': 'Subtitle text',
          'leadingIcon': 0xe318,
          'color': 0xFFFFFFFF,
          'textColor': 0xFF000000,
        };
      case 'BottomNavigationBar':
        return {
          'color': 0xFFFFFFFF,
          'selectedColor': 0xFF6750A4,
          'item1': 'Home',
          'item2': 'Search',
          'item3': 'Profile',
        };
      case 'AppBar':
        return {
          'title': 'App Bar',
          'color': 0xFF6750A4,
          'textColor': 0xFFFFFFFF,
          'centerTitle': true,
        };
      case 'TabBar':
        return {
          'tab1': 'Tab 1',
          'tab2': 'Tab 2',
          'tab3': 'Tab 3',
          'color': 0xFF6750A4,
          'indicatorColor': 0xFFFFFFFF,
        };
      case 'SearchBar':
        return {
          'hintText': 'Search...',
          'color': 0xFFF3EFF4,
          'borderRadius': 28.0,
        };
      case 'NavigationDrawer':
        return {
          'title': 'Menu',
          'color': 0xFFFFFBFE,
          'item1': 'Home',
          'item2': 'Settings',
          'item3': 'About',
        };
      case 'SnackBar':
        return {
          'message': 'Snackbar message',
          'color': 0xFF323232,
          'textColor': 0xFFFFFFFF,
        };
      case 'AlertDialog':
        return {
          'title': 'Alert',
          'content': 'Dialog content here',
          'color': 0xFFFFFFFF,
        };
      default:
        return {'color': 0xFF6750A4};
    }
  }

  WidgetProperty copyWith({
    String? type,
    double? x,
    double? y,
    double? width,
    double? height,
    Map<String, dynamic>? props,
    int? zIndex,
  }) {
    return WidgetProperty(
      id: id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      props: props ?? Map.from(this.props),
      zIndex: zIndex ?? this.zIndex,
    );
  }
}

// ─────────────────────────────────────────────
// CANVAS SCREEN MODEL
// ─────────────────────────────────────────────
@HiveType(typeId: 1)
class CanvasScreen extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<WidgetProperty> widgets;

  @HiveField(3)
  int backgroundColor;

  CanvasScreen({
    String? id,
    this.name = 'Screen 1',
    List<WidgetProperty>? widgets,
    this.backgroundColor = 0xFFFFFFFF,
  })  : id = id ?? _uuid.v4(),
        widgets = widgets ?? [];

  CanvasScreen copyWith({
    String? name,
    List<WidgetProperty>? widgets,
    int? backgroundColor,
  }) {
    return CanvasScreen(
      id: id,
      name: name ?? this.name,
      widgets: widgets ?? List.from(this.widgets),
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

// ─────────────────────────────────────────────
// PROJECT MODEL
// ─────────────────────────────────────────────
@HiveType(typeId: 2)
class GaxProject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<CanvasScreen> screens;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  int thumbnailColor;

  GaxProject({
    String? id,
    required this.name,
    this.description = '',
    List<CanvasScreen>? screens,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.thumbnailColor = 0xFF6750A4,
  })  : id = id ?? _uuid.v4(),
        screens = screens ?? [CanvasScreen(name: 'Screen 1')],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  GaxProject copyWith({
    String? name,
    String? description,
    List<CanvasScreen>? screens,
    int? thumbnailColor,
  }) {
    return GaxProject(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      screens: screens ?? List.from(this.screens),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      thumbnailColor: thumbnailColor ?? this.thumbnailColor,
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET CATALOG (40+ widgets)
// ─────────────────────────────────────────────
class WidgetCatalog {
  static const List<WidgetCategory> categories = [
    WidgetCategory(
      name: 'Basic',
      icon: Icons.widgets,
      widgets: [
        'Container', 'Text', 'Icon', 'Image',
        'SizedBox', 'Divider', 'Spacer',
      ],
    ),
    WidgetCategory(
      name: 'Buttons',
      icon: Icons.smart_button,
      widgets: [
        'ElevatedButton', 'OutlinedButton', 'TextButton',
        'IconButton', 'FloatingActionButton', 'FilledButton',
      ],
    ),
    WidgetCategory(
      name: 'Input',
      icon: Icons.input,
      widgets: [
        'TextField', 'SearchBar', 'Switch',
        'Checkbox', 'Slider', 'RadioButton', 'DropdownButton',
      ],
    ),
    WidgetCategory(
      name: 'Display',
      icon: Icons.dashboard,
      widgets: [
        'Card', 'Chip', 'Badge', 'CircleAvatar',
        'LinearProgressIndicator', 'CircularProgressIndicator',
        'Tooltip', 'Placeholder',
      ],
    ),
    WidgetCategory(
      name: 'Layout',
      icon: Icons.view_quilt,
      widgets: [
        'Column', 'Row', 'Stack', 'Wrap',
        'GridView', 'ListView', 'Expanded', 'Padding',
      ],
    ),
    WidgetCategory(
      name: 'Navigation',
      icon: Icons.navigation,
      widgets: [
        'AppBar', 'BottomNavigationBar', 'TabBar',
        'NavigationDrawer', 'NavigationBar', 'Breadcrumb',
      ],
    ),
    WidgetCategory(
      name: 'Overlay',
      icon: Icons.layers,
      widgets: [
        'AlertDialog', 'SnackBar', 'BottomSheet',
        'PopupMenu', 'Tooltip', 'Dialog',
      ],
    ),
    WidgetCategory(
      name: 'Scroll',
      icon: Icons.swap_vert,
      widgets: [
        'SingleChildScrollView', 'CustomScrollView',
        'PageView', 'TabBarView', 'ListTile',
      ],
    ),
  ];
}

class WidgetCategory {
  final String name;
  final IconData icon;
  final List<String> widgets;

  const WidgetCategory({
    required this.name,
    required this.icon,
    required this.widgets,
  });
}
