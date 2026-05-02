// lib/models/app_models.dart
// GAX Forge - Core Data Models with Hive persistence

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

const _uuid = Uuid();

// ─────────────────────────────────────────────
// WIDGET PROPERTY MODEL
// ─────────────────────────────────────────────
@HiveType(typeId: 0)
class WidgetProperty extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String type;
  @HiveField(2) double x;
  @HiveField(3) double y;
  @HiveField(4) double width;
  @HiveField(5) double height;
  @HiveField(6) Map<String, dynamic> props;
  @HiveField(7) int zIndex;
  @HiveField(8) String? customName; // for Custom Widgets

  WidgetProperty({
    String? id,
    required this.type,
    this.x = 0,
    this.y = 0,
    this.width = 120,
    this.height = 60,
    Map<String, dynamic>? props,
    this.zIndex = 0,
    this.customName,
  })  : id = id ?? _uuid.v4(),
        props = props ?? defaultProps(type);

  // ── Default props per widget type ─────────────
  static Map<String, dynamic> defaultProps(String type) {
    switch (type) {
      // ── Basic ──
      case 'Text':
        return {
          'text': 'Hello World',
          'fontSize': 16.0, 'fontWeight': 'normal',
          'fontStyle': 'normal', 'color': 0xFF212121,
          'textAlign': 'left', 'maxLines': 0,
          'overflow': 'ellipsis', 'letterSpacing': 0.0,
          'lineHeight': 1.0, 'decoration': 'none',
          'softWrap': true,
        };
      case 'Container':
        return {
          'color': 0xFF2196F3, 'borderRadius': 8.0,
          'topLeftRadius': -1.0, 'topRightRadius': -1.0,
          'bottomLeftRadius': -1.0, 'bottomRightRadius': -1.0,
          'padding': 8.0, 'paddingLeft': -1.0, 'paddingRight': -1.0,
          'paddingTop': -1.0, 'paddingBottom': -1.0,
          'margin': 0.0, 'opacity': 1.0,
          'hasBorder': false, 'borderColor': 0xFF000000,
          'borderWidth': 1.0, 'borderStyle': 'solid',
          'hasGradient': false, 'gradientStart': 0xFF6750A4,
          'gradientEnd': 0xFF03DAC6, 'gradientAngle': 'vertical',
          'hasShadow': false, 'shadowColor': 0x40000000,
          'shadowBlur': 8.0, 'shadowX': 0.0, 'shadowY': 4.0,
          'clipBehavior': 'antiAlias',
          'alignment': 'center',
        };
      case 'Icon':
        return {
          'iconCode': 0xe318, 'color': 0xFF6750A4,
          'size': 32.0, 'shadows': false,
          'shadowColor': 0x40000000,
        };
      case 'Image':
        return {
          'placeholder': true, 'color': 0xFFE0E0E0,
          'fit': 'cover', 'borderRadius': 0.0,
          'url': '',
        };
      case 'SizedBox':
        return {'showBorder': true, 'borderColor': 0xFFBBBBBB};
      case 'Divider':
        return {
          'color': 0xFFCAC4D0, 'thickness': 1.0,
          'indent': 0.0, 'endIndent': 0.0,
          'vertical': false,
        };
      case 'Spacer':
        return {'flex': 1};
      case 'Placeholder':
        return {'color': 0xFF6750A4, 'strokeWidth': 2.0};

      // ── Buttons ──
      case 'ElevatedButton':
        return {
          'text': 'Button', 'color': 0xFF6750A4,
          'textColor': 0xFFFFFFFF, 'borderRadius': 12.0,
          'fontSize': 14.0, 'fontWeight': 'bold',
          'elevation': 2.0, 'padding': 16.0,
          'iconCode': -1, 'iconPosition': 'left',
          'disabled': false,
          'navigateTo': '',
        };
      case 'OutlinedButton':
        return {
          'text': 'Outlined', 'color': 0xFF6750A4,
          'borderRadius': 12.0, 'fontSize': 14.0,
          'borderWidth': 1.0, 'padding': 16.0,
          'iconCode': -1, 'disabled': false,
          'navigateTo': '',
        };
      case 'TextButton':
        return {
          'text': 'Text Button', 'color': 0xFF6750A4,
          'fontSize': 14.0, 'fontWeight': 'normal',
          'padding': 8.0, 'disabled': false,
          'navigateTo': '',
        };
      case 'FilledButton':
        return {
          'text': 'Filled', 'color': 0xFF6750A4,
          'textColor': 0xFFFFFFFF, 'borderRadius': 12.0,
          'fontSize': 14.0, 'disabled': false,
          'navigateTo': '',
        };
      case 'FilledTonalButton':
        return {
          'text': 'Tonal', 'color': 0xFFE8DEF8,
          'textColor': 0xFF21005D, 'borderRadius': 12.0,
          'fontSize': 14.0,
          'navigateTo': '',
        };
      case 'IconButton':
        return {
          'iconCode': 0xe318, 'color': 0xFF6750A4,
          'size': 24.0, 'style': 'standard',
          'bgColor': 0x00000000, 'tooltip': '',
          'disabled': false,
          'navigateTo': '',
        };
      case 'FloatingActionButton':
        return {
          'iconCode': 0xe145, 'color': 0xFF6750A4,
          'iconColor': 0xFFFFFFFF, 'mini': false,
          'extended': false, 'label': 'Create',
          'elevation': 4.0, 'tooltip': '',
          'shape': 'circle',
          'navigateTo': '',
        };
      case 'SegmentedButton':
        return {
          'seg1': 'Day', 'seg2': 'Week', 'seg3': 'Month',
          'selected': 0, 'color': 0xFF6750A4,
          'multiSelect': false,
        };

      // ── Input ──
      case 'TextField':
        return {
          'hintText': 'Enter text...', 'labelText': 'Label',
          'color': 0xFF6750A4, 'borderRadius': 8.0,
          'borderStyle': 'outline', 'filled': true,
          'fillColor': 0xFFF3EFF4, 'prefixIcon': -1,
          'suffixIcon': -1, 'maxLines': 1,
          'obscureText': false, 'enabled': true,
          'helperText': '', 'errorText': '',
          'counterText': false,
        };
      case 'SearchBar':
        return {
          'hintText': 'Search...', 'color': 0xFFF3EFF4,
          'borderRadius': 28.0, 'elevation': 1.0,
          'leadingIcon': 0xe8b6, 'trailingIcon': 0xe5cd,
          'padding': 16.0,
        };
      case 'Switch':
        return {
          'value': true, 'activeColor': 0xFF6750A4,
          'inactiveColor': 0xFFE8DEF8, 'thumbColor': 0xFFFFFFFF,
          'label': '', 'labelPosition': 'right',
          'size': 'normal',
        };
      case 'Checkbox':
        return {
          'value': true, 'activeColor': 0xFF6750A4,
          'checkColor': 0xFFFFFFFF, 'label': '',
          'shape': 'square', 'borderWidth': 2.0,
          'tristate': false,
        };
      case 'Slider':
        return {
          'value': 0.5, 'min': 0.0, 'max': 1.0,
          'activeColor': 0xFF6750A4, 'inactiveColor': 0xFFE8DEF8,
          'thumbColor': 0xFF6750A4, 'divisions': 0,
          'showLabel': true, 'discrete': false,
        };
      case 'RangeSlider':
        return {
          'startValue': 0.2, 'endValue': 0.8,
          'min': 0.0, 'max': 1.0,
          'activeColor': 0xFF6750A4, 'inactiveColor': 0xFFE8DEF8,
          'divisions': 0,
        };
      case 'RadioButton':
        return {
          'value': true, 'color': 0xFF6750A4,
          'label': 'Option 1', 'groupValue': 'a',
        };
      case 'DropdownButton':
        return {
          'value': 'Option 1',
          'items': 'Option 1,Option 2,Option 3',
          'color': 0xFF6750A4, 'borderRadius': 8.0,
          'filled': true, 'fillColor': 0xFFF3EFF4,
          'labelText': 'Select',
        };
      case 'DatePicker':
        return {
          'label': 'Pick Date', 'color': 0xFF6750A4,
          'borderRadius': 8.0, 'filled': true,
        };
      case 'TimePicker':
        return {
          'label': 'Pick Time', 'color': 0xFF6750A4,
          'borderRadius': 8.0,
        };

      // ── Display ──
      case 'Card':
        return {
          'color': 0xFFFFFFFF, 'elevation': 4.0,
          'borderRadius': 12.0, 'shadowColor': 0x40000000,
          'margin': 4.0, 'clipBehavior': 'antiAlias',
          'variant': 'elevated', 'borderColor': 0xFFCAC4D0,
          'borderWidth': 1.0,
          'navigateTo': '',
        };
      case 'Chip':
        return {
          'label': 'Chip', 'color': 0xFFE8DEF8,
          'textColor': 0xFF6750A4, 'borderRadius': 8.0,
          'leadingIcon': -1, 'trailingIcon': -1,
          'avatar': false, 'avatarText': 'A',
          'avatarColor': 0xFF6750A4, 'selected': false,
          'selectedColor': 0xFF6750A4, 'elevation': 0.0,
          'padding': 8.0,
          'navigateTo': '',
        };
      case 'Badge':
        return {
          'label': '9+', 'color': 0xFFB3261E,
          'textColor': 0xFFFFFFFF, 'childText': 'Inbox',
          'fontSize': 12.0, 'padding': 4.0,
          'alignment': 'topRight',
        };
      case 'CircleAvatar':
        return {
          'color': 0xFF6750A4, 'radius': 30.0,
          'text': 'A', 'textColor': 0xFFFFFFFF,
          'fontSize': 18.0, 'fontWeight': 'bold',
          'hasImage': false, 'borderColor': 0x00000000,
          'borderWidth': 0.0,
        };
      case 'LinearProgressIndicator':
        return {
          'value': 0.6, 'color': 0xFF6750A4,
          'backgroundColor': 0xFFE8DEF8, 'minHeight': 4.0,
          'borderRadius': 4.0, 'indeterminate': false,
          'valueLabel': false,
        };
      case 'CircularProgressIndicator':
        return {
          'color': 0xFF6750A4, 'backgroundColor': 0xFFE8DEF8,
          'strokeWidth': 4.0, 'indeterminate': true,
          'value': 0.7, 'strokeCap': 'round',
        };
      case 'Tooltip':
        return {
          'message': 'Tooltip text', 'color': 0xFF323232,
          'textColor': 0xFFFFFFFF, 'childText': 'Hover me',
          'preferBelow': true, 'padding': 8.0,
          'borderRadius': 4.0,
        };
      case 'ExpansionTile':
        return {
          'title': 'Expandable Item', 'subtitle': '',
          'color': 0xFFFFFFFF, 'textColor': 0xFF212121,
          'iconColor': 0xFF6750A4, 'expanded': false,
          'childCount': 3, 'childLabel': 'Item',
        };
      case 'DataTable':
        return {
          'columns': 'Name,Age,City',
          'rows': '3',
          'color': 0xFFFFFFFF, 'headerColor': 0xFFF3EFF4,
          'textColor': 0xFF212121, 'dividerColor': 0xFFE0E0E0,
          'elevation': 1.0, 'borderRadius': 8.0,
        };
      case 'StepperWidget':
        return {
          'steps': 3, 'currentStep': 1,
          'color': 0xFF6750A4, 'type': 'horizontal',
        };

      // ── Navigation ──
      case 'AppBar':
        return {
          'title': 'App Bar', 'color': 0xFF6750A4,
          'textColor': 0xFFFFFFFF, 'centerTitle': true,
          'elevation': 0.0, 'leading': 'menu',
          'actions': 1, 'titleFontSize': 20.0,
          'titleFontWeight': 'bold', 'scrolledUnder': false,
          'large': false, 'medium': false,
        };
      case 'BottomNavigationBar':
        return {
          'color': 0xFFFFFFFF, 'selectedColor': 0xFF6750A4,
          'unselectedColor': 0xFF9E9E9E,
          'item1': 'Home', 'icon1': 0xe88a,
          'item2': 'Search', 'icon2': 0xe8b6,
          'item3': 'Profile', 'icon3': 0xe7fd,
          'item4': '', 'icon4': -1,
          'item5': '', 'icon5': -1,
          'itemCount': 3, 'currentIndex': 0,
          'type': 'fixed', 'showLabels': true,
          'elevation': 8.0,
        };
      case 'NavigationBar':
        return {
          'color': 0xFFFFFFFF, 'indicatorColor': 0xFFE8DEF8,
          'selectedColor': 0xFF6750A4, 'height': 80.0,
          'item1': 'Home', 'item2': 'Explore', 'item3': 'Library',
          'currentIndex': 0, 'labelBehavior': 'alwaysShow',
          'elevation': 3.0,
        };
      case 'TabBar':
        return {
          'tab1': 'Tab 1', 'tab2': 'Tab 2', 'tab3': 'Tab 3',
          'tab4': '', 'tabCount': 3,
          'color': 0xFF6750A4, 'indicatorColor': 0xFFFFFFFF,
          'labelColor': 0xFFFFFFFF, 'unselectedColor': 0xCCFFFFFF,
          'indicatorWeight': 3.0, 'isScrollable': false,
          'indicatorStyle': 'underline',
        };
      case 'NavigationDrawer':
        return {
          'title': 'Menu', 'subtitle': 'v1.0',
          'color': 0xFFFFFBFE, 'selectedColor': 0xFF6750A4,
          'item1': 'Home', 'icon1': 0xe88a,
          'item2': 'Settings', 'icon2': 0xe8b8,
          'item3': 'About', 'icon3': 0xe3b4,
          'itemCount': 3, 'selectedIndex': 0,
          'showHeader': true, 'headerColor': 0xFF6750A4,
        };
      case 'Breadcrumb':
        return {
          'items': 'Home > Products > Detail',
          'color': 0xFF6750A4, 'separatorColor': 0xFF9E9E9E,
          'fontSize': 13.0,
        };

      // ── Layout ──
      case 'Column':
        return {
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'start',
          'mainAxisSize': 'min',
          'color': 0x0F6750A4,
          'childCount': 3, 'spacing': 8.0,
        };
      case 'Row':
        return {
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'mainAxisSize': 'min',
          'color': 0x0F6750A4,
          'childCount': 3, 'spacing': 8.0,
        };
      case 'Stack':
        return {
          'alignment': 'topLeft', 'color': 0x0F6750A4,
          'childCount': 2, 'fit': 'loose',
        };
      case 'Wrap':
        return {
          'spacing': 8.0, 'runSpacing': 8.0,
          'color': 0x0F6750A4, 'direction': 'horizontal',
          'alignment': 'start', 'chipCount': 4,
        };
      case 'GridView':
        return {
          'crossAxisCount': 2, 'mainAxisSpacing': 8.0,
          'crossAxisSpacing': 8.0, 'childAspectRatio': 1.0,
          'color': 0x0F6750A4, 'padding': 8.0,
        };
      case 'ListView':
        return {
          'itemCount': 5, 'color': 0xFFFFFFFF,
          'padding': 8.0, 'separators': true,
          'separatorColor': 0xFFE0E0E0, 'scrollDirection': 'vertical',
        };
      case 'Expanded':
        return {'flex': 1, 'color': 0x0F6750A4};
      case 'Padding':
        return {
          'padding': 16.0, 'paddingLeft': -1.0,
          'paddingRight': -1.0, 'paddingTop': -1.0,
          'paddingBottom': -1.0, 'color': 0x0F6750A4,
        };
      case 'Center':
        return {'color': 0x0F6750A4, 'widthFactor': 1.0, 'heightFactor': 1.0};
      case 'Align':
        return {'alignment': 'center', 'color': 0x0F6750A4};
      case 'FractionallySizedBox':
        return {'widthFactor': 0.5, 'heightFactor': 0.5, 'color': 0x0F6750A4};
      case 'AspectRatio':
        return {'aspectRatio': 1.0, 'color': 0x0F6750A4};
      case 'ConstrainedBox':
        return {
          'minWidth': 50.0, 'maxWidth': 300.0,
          'minHeight': 30.0, 'maxHeight': 200.0,
          'color': 0x0F6750A4,
        };
      case 'IntrinsicWidth':
        return {'color': 0x0F6750A4};
      case 'IntrinsicHeight':
        return {'color': 0x0F6750A4};
      case 'SingleChildScrollView':
        return {'scrollDirection': 'vertical', 'color': 0xFFFFFFFF, 'padding': 8.0};
      case 'CustomScrollView':
        return {'color': 0xFFFFFFFF};
      case 'PageView':
        return {'pageCount': 3, 'color': 0xFFE8DEF8, 'indicator': true};
      case 'TabBarView':
        return {'tabCount': 3, 'color': 0xFFFFFFFF};
      case 'AnimatedContainer':
        return {
          'color': 0xFF6750A4, 'borderRadius': 8.0,
          'width2': 200.0, 'height2': 100.0,
          'duration': 500.0,
        };
      case 'AnimatedOpacity':
        return {'opacity': 0.5, 'color': 0xFF6750A4, 'duration': 500.0};

      // ── Overlay ──
      case 'AlertDialog':
        return {
          'title': 'Alert Dialog', 'content': 'This is the dialog content.',
          'color': 0xFFFFFFFF, 'titleColor': 0xFF212121,
          'contentColor': 0xFF757575, 'buttonColor': 0xFF6750A4,
          'cancelText': 'Cancel', 'confirmText': 'Confirm',
          'icon': -1, 'borderRadius': 16.0,
        };
      case 'SnackBar':
        return {
          'message': 'Snackbar message here',
          'color': 0xFF323232, 'textColor': 0xFFFFFFFF,
          'actionLabel': 'UNDO', 'actionColor': 0xFF6750A4,
          'behavior': 'floating', 'borderRadius': 8.0,
          'duration': 4, 'hasAction': true,
        };
      case 'BottomSheet':
        return {
          'title': 'Bottom Sheet', 'color': 0xFFFFFFFF,
          'handleColor': 0xFFCAC4D0, 'borderRadius': 28.0,
          'itemCount': 3, 'showHandle': true,
        };
      case 'PopupMenu':
        return {
          'color': 0xFFFFFFFF, 'elevation': 4.0,
          'borderRadius': 8.0, 'itemCount': 3,
          'iconCode': 0xe5c3,
        };
      case 'Dialog':
        return {
          'title': 'Dialog', 'color': 0xFFFFFFFF,
          'borderRadius': 16.0, 'elevation': 6.0,
        };
      case 'BannerWidget':
        return {
          'message': 'This is a Material Banner',
          'color': 0xFFE8DEF8, 'textColor': 0xFF21005D,
          'actionLabel': 'Dismiss', 'actionColor': 0xFF6750A4,
          'icon': 0xe3b4,
        };

      // ── Scroll ──
      case 'ListTile':
        return {
          'title': 'List Item', 'subtitle': 'Subtitle text',
          'leadingIcon': 0xe318, 'trailingIcon': 0xe5cf,
          'color': 0xFFFFFFFF, 'textColor': 0xFF212121,
          'subtitleColor': 0xFF757575, 'selectedColor': 0xFF6750A4,
          'selected': false, 'enabled': true,
          'dense': false, 'contentPadding': 16.0,
          'tileShape': 'rectangle', 'iconColor': 0xFF6750A4,
          'minHeight': 56.0, 'isThreeLine': false,
          'navigateTo': '',
        };

      // ── Custom ──
      case 'CustomWidget':
        return {
          'name': 'MyWidget', 'color': 0xFF6750A4,
          'text': 'Custom Widget', 'textColor': 0xFFFFFFFF,
          'borderRadius': 12.0, 'borderColor': 0xFF6750A4,
          'borderWidth': 2.0, 'hasBorder': true,
          'hasGradient': false, 'gradientStart': 0xFF6750A4,
          'gradientEnd': 0xFF03DAC6, 'elevation': 4.0,
          'icon': -1, 'iconColor': 0xFFFFFFFF,
          'showIcon': false, 'fontSize': 14.0,
          'fontWeight': 'bold', 'padding': 16.0,
          'opacity': 1.0,
        };

      default:
        return {'color': 0xFF6750A4};
    }
  }

  WidgetProperty copyWith({
    String? type, double? x, double? y,
    double? width, double? height,
    Map<String, dynamic>? props, int? zIndex, String? customName,
  }) {
    return WidgetProperty(
      id: id, type: type ?? this.type,
      x: x ?? this.x, y: y ?? this.y,
      width: width ?? this.width, height: height ?? this.height,
      props: props ?? Map.from(this.props),
      zIndex: zIndex ?? this.zIndex,
      customName: customName ?? this.customName,
    );
  }

  // JSON export
  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'x': x, 'y': y,
    'width': width, 'height': height,
    'props': props, 'zIndex': zIndex,
    if (customName != null) 'customName': customName,
  };

  factory WidgetProperty.fromJson(Map<String, dynamic> json) => WidgetProperty(
    id: json['id'] as String?,
    type: json['type'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
    props: Map<String, dynamic>.from(json['props'] as Map),
    zIndex: json['zIndex'] as int? ?? 0,
    customName: json['customName'] as String?,
  );
}

// ─────────────────────────────────────────────
// CANVAS SCREEN MODEL
// ─────────────────────────────────────────────
@HiveType(typeId: 1)
class CanvasScreen extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) List<WidgetProperty> widgets;
  @HiveField(3) int backgroundColor;
  @HiveField(4) String screenSize; // e.g. 'iphone_15_pro', 'pixel_8', 'tablet_ipad'

  CanvasScreen({
    String? id, this.name = 'Screen 1',
    List<WidgetProperty>? widgets,
    this.backgroundColor = 0xFFFFFFFF,
    this.screenSize = 'pixel_8',
  })  : id = id ?? _uuid.v4(),
        widgets = widgets ?? [];

  CanvasScreen copyWith({
    String? name, List<WidgetProperty>? widgets,
    int? backgroundColor, String? screenSize,
  }) {
    return CanvasScreen(
      id: id, name: name ?? this.name,
      widgets: widgets ?? List.from(this.widgets),
      backgroundColor: backgroundColor ?? this.backgroundColor,
      screenSize: screenSize ?? this.screenSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'backgroundColor': backgroundColor,
    'screenSize': screenSize,
    'widgets': widgets.map((w) => w.toJson()).toList(),
  };

  factory CanvasScreen.fromJson(Map<String, dynamic> json) => CanvasScreen(
    id: json['id'] as String?,
    name: json['name'] as String,
    backgroundColor: json['backgroundColor'] as int? ?? 0xFFFFFFFF,
    screenSize: json['screenSize'] as String? ?? 'pixel_8',
    widgets: (json['widgets'] as List)
        .map((w) => WidgetProperty.fromJson(Map<String, dynamic>.from(w as Map)))
        .toList(),
  );
}

// ─────────────────────────────────────────────
// PROJECT MODEL
// ─────────────────────────────────────────────
@HiveType(typeId: 2)
class GaxProject extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String description;
  @HiveField(3) List<CanvasScreen> screens;
  @HiveField(4) DateTime createdAt;
  @HiveField(5) DateTime updatedAt;
  @HiveField(6) int thumbnailColor;

  GaxProject({
    String? id, required this.name,
    this.description = '',
    List<CanvasScreen>? screens,
    DateTime? createdAt, DateTime? updatedAt,
    this.thumbnailColor = 0xFF6750A4,
  })  : id = id ?? _uuid.v4(),
        screens = screens ?? [CanvasScreen(name: 'Screen 1')],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  GaxProject copyWith({
    String? name, String? description,
    List<CanvasScreen>? screens, int? thumbnailColor,
  }) {
    return GaxProject(
      id: id, name: name ?? this.name,
      description: description ?? this.description,
      screens: screens ?? List.from(this.screens),
      createdAt: createdAt, updatedAt: DateTime.now(),
      thumbnailColor: thumbnailColor ?? this.thumbnailColor,
    );
  }

  // JSON import/export
  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'thumbnailColor': thumbnailColor,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'screens': screens.map((s) => s.toJson()).toList(),
    'version': '2.0',
  };

  factory GaxProject.fromJson(Map<String, dynamic> json) => GaxProject(
    id: json['id'] as String?,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    thumbnailColor: json['thumbnailColor'] as int? ?? 0xFF6750A4,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    screens: (json['screens'] as List)
        .map((s) => CanvasScreen.fromJson(Map<String, dynamic>.from(s as Map)))
        .toList(),
  );
}

// ─────────────────────────────────────────────
// WIDGET CATALOG (100+ widgets, 10 categories)
// ─────────────────────────────────────────────
class WidgetCatalog {
  static const List<WidgetCategory> categories = [
    WidgetCategory(name: 'Basic', icon: Icons.crop_square_rounded, widgets: [
      'Container', 'Text', 'Icon', 'Image',
      'SizedBox', 'Divider', 'Spacer', 'Placeholder',
    ]),
    WidgetCategory(name: 'Buttons', icon: Icons.smart_button_rounded, widgets: [
      'ElevatedButton', 'OutlinedButton', 'TextButton', 'FilledButton',
      'FilledTonalButton', 'IconButton', 'FloatingActionButton', 'SegmentedButton',
    ]),
    WidgetCategory(name: 'Input', icon: Icons.input_rounded, widgets: [
      'TextField', 'SearchBar', 'Switch', 'Checkbox',
      'Slider', 'RangeSlider', 'RadioButton', 'DropdownButton',
      'DatePicker', 'TimePicker',
    ]),
    WidgetCategory(name: 'Display', icon: Icons.dashboard_rounded, widgets: [
      'Card', 'Chip', 'Badge', 'CircleAvatar',
      'LinearProgressIndicator', 'CircularProgressIndicator',
      'Tooltip', 'ExpansionTile', 'DataTable', 'StepperWidget',
    ]),
    WidgetCategory(name: 'Layout', icon: Icons.view_quilt_rounded, widgets: [
      'Column', 'Row', 'Stack', 'Wrap',
      'GridView', 'ListView', 'Expanded', 'Padding',
      'Center', 'Align', 'FractionallySizedBox', 'AspectRatio',
      'ConstrainedBox', 'IntrinsicWidth', 'IntrinsicHeight',
      'SingleChildScrollView', 'AnimatedContainer', 'AnimatedOpacity',
    ]),
    WidgetCategory(name: 'Navigation', icon: Icons.navigation_rounded, widgets: [
      'AppBar', 'BottomNavigationBar', 'NavigationBar', 'TabBar',
      'NavigationDrawer', 'Breadcrumb',
    ]),
    WidgetCategory(name: 'Overlay', icon: Icons.layers_rounded, widgets: [
      'AlertDialog', 'SnackBar', 'BottomSheet', 'PopupMenu',
      'Dialog', 'BannerWidget',
    ]),
    WidgetCategory(name: 'Scroll', icon: Icons.swap_vert_rounded, widgets: [
      'ListTile', 'SingleChildScrollView', 'CustomScrollView',
      'PageView', 'TabBarView',
    ]),
    WidgetCategory(name: 'Custom', icon: Icons.auto_awesome_rounded, widgets: [
      'CustomWidget',
    ]),
  ];

  static int totalCount() =>
      categories.fold(0, (sum, c) => sum + c.widgets.length);
}

class WidgetCategory {
  final String name;
  final IconData icon;
  final List<String> widgets;
  const WidgetCategory({required this.name, required this.icon, required this.widgets});
}

// ─────────────────────────────────────────────
// HIVE TYPE ADAPTERS
// ─────────────────────────────────────────────
class WidgetPropertyAdapter extends TypeAdapter<WidgetProperty> {
  @override
  final int typeId = 0;

  @override
  WidgetProperty read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WidgetProperty(
      id: fields[0] as String?,
      type: fields[1] as String,
      x: fields[2] as double,
      y: fields[3] as double,
      width: fields[4] as double,
      height: fields[5] as double,
      props: (fields[6] as Map).cast<String, dynamic>(),
      zIndex: fields[7] as int,
      customName: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WidgetProperty obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.type)
      ..writeByte(2)..write(obj.x)
      ..writeByte(3)..write(obj.y)
      ..writeByte(4)..write(obj.width)
      ..writeByte(5)..write(obj.height)
      ..writeByte(6)..write(obj.props)
      ..writeByte(7)..write(obj.zIndex)
      ..writeByte(8)..write(obj.customName);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetPropertyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class CanvasScreenAdapter extends TypeAdapter<CanvasScreen> {
  @override
  final int typeId = 1;

  @override
  CanvasScreen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CanvasScreen(
      id: fields[0] as String?,
      name: fields[1] as String,
      widgets: (fields[2] as List).cast<WidgetProperty>(),
      backgroundColor: fields[3] as int,
      screenSize: fields[4] as String? ?? 'pixel_8',
    );
  }

  @override
  void write(BinaryWriter writer, CanvasScreen obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.widgets)
      ..writeByte(3)..write(obj.backgroundColor)
      ..writeByte(4)..write(obj.screenSize);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasScreenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class GaxProjectAdapter extends TypeAdapter<GaxProject> {
  @override
  final int typeId = 2;

  @override
  GaxProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GaxProject(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String,
      screens: (fields[3] as List).cast<CanvasScreen>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      thumbnailColor: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GaxProject obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.description)
      ..writeByte(3)..write(obj.screens)
      ..writeByte(4)..write(obj.createdAt)
      ..writeByte(5)..write(obj.updatedAt)
      ..writeByte(6)..write(obj.thumbnailColor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GaxProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
