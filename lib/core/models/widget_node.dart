import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ── Widget Types ──────────────────────────────────────────────
enum WType {
  container, row, column, stack,
  text, image, button, iconButton,
  textField, card, icon, switchW,
  slider, checkbox, divider, listTile,
  circleAvatar, listView, gridView, appBar,
}

extension WTypeInfo on WType {
  String get name {
    const names = {
      WType.container: 'Container', WType.row: 'Row',
      WType.column: 'Column', WType.stack: 'Stack',
      WType.text: 'Text', WType.image: 'Image',
      WType.button: 'Button', WType.iconButton: 'IconButton',
      WType.textField: 'TextField', WType.card: 'Card',
      WType.icon: 'Icon', WType.switchW: 'Switch',
      WType.slider: 'Slider', WType.checkbox: 'Checkbox',
      WType.divider: 'Divider', WType.listTile: 'ListTile',
      WType.circleAvatar: 'CircleAvatar', WType.listView: 'ListView',
      WType.gridView: 'GridView', WType.appBar: 'AppBar',
    };
    return names[this] ?? 'Widget';
  }

  IconData get widgetIcon {
    const icons = {
      WType.container: Icons.crop_square_rounded,
      WType.row: Icons.table_rows_outlined,
      WType.column: Icons.view_column_outlined,
      WType.stack: Icons.layers_outlined,
      WType.text: Icons.text_fields_rounded,
      WType.image: Icons.image_outlined,
      WType.button: Icons.smart_button_outlined,
      WType.iconButton: Icons.touch_app_outlined,
      WType.textField: Icons.input_rounded,
      WType.card: Icons.credit_card_outlined,
      WType.icon: Icons.emoji_emotions_outlined,
      WType.switchW: Icons.toggle_on_outlined,
      WType.slider: Icons.tune_rounded,
      WType.checkbox: Icons.check_box_outlined,
      WType.divider: Icons.horizontal_rule_rounded,
      WType.listTile: Icons.list_alt_rounded,
      WType.circleAvatar: Icons.account_circle_outlined,
      WType.listView: Icons.format_list_bulleted_rounded,
      WType.gridView: Icons.grid_view_rounded,
      WType.appBar: Icons.web_asset_outlined,
    };
    return icons[this] ?? Icons.widgets_outlined;
  }

  bool get isLayout => [
    WType.row, WType.column, WType.stack,
    WType.container, WType.card,
    WType.listView, WType.gridView,
  ].contains(this);

  bool get canHaveChildren => isLayout;

  String get category {
    if ([WType.container, WType.row, WType.column, WType.stack,
         WType.listView, WType.gridView].contains(this)) return 'Layout';
    if ([WType.text, WType.image, WType.icon,
         WType.divider, WType.circleAvatar].contains(this)) return 'Basic';
    if ([WType.button, WType.iconButton, WType.textField,
         WType.switchW, WType.slider, WType.checkbox].contains(this)) return 'Input';
    if ([WType.card, WType.listTile, WType.appBar].contains(this)) return 'Material';
    return 'Other';
  }
}

// ── WidgetNode — core data model ──────────────────────────────
class WidgetNode {
  final String id;
  WType type;

  // Position & size on canvas (absolute, for free-placement in stack/canvas)
  double x;
  double y;
  double width;
  double height;

  // Layer properties
  bool visible;
  bool locked;
  String? name; // Custom layer name

  // All widget-specific properties
  Map<String, dynamic> props;

  // Children (for layout widgets)
  List<WidgetNode> children;

  // Z-index (layer order — higher = on top)
  int zIndex;

  WidgetNode({
    String? id,
    required this.type,
    this.x = 0,
    this.y = 0,
    double? width,
    double? height,
    this.visible = true,
    this.locked = false,
    this.name,
    Map<String, dynamic>? props,
    List<WidgetNode>? children,
    this.zIndex = 0,
  })  : id = id ?? const Uuid().v4(),
        width = width ?? _defaultWidth(type),
        height = height ?? _defaultHeight(type),
        props = props ?? _defaultProps(type),
        children = children ?? [];

  // ── Default sizes ─────────────────────────────────────────
  static double _defaultWidth(WType t) {
    switch (t) {
      case WType.text: return 200;
      case WType.button: return 160;
      case WType.iconButton: return 48;
      case WType.textField: return 240;
      case WType.icon: return 40;
      case WType.switchW: return 60;
      case WType.slider: return 220;
      case WType.checkbox: return 40;
      case WType.divider: return 300;
      case WType.circleAvatar: return 56;
      case WType.listTile: return 320;
      case WType.appBar: return 360;
      case WType.card: return 280;
      default: return 200;
    }
  }

  static double _defaultHeight(WType t) {
    switch (t) {
      case WType.text: return 32;
      case WType.button: return 44;
      case WType.iconButton: return 48;
      case WType.textField: return 52;
      case WType.icon: return 40;
      case WType.switchW: return 40;
      case WType.slider: return 48;
      case WType.checkbox: return 40;
      case WType.divider: return 16;
      case WType.circleAvatar: return 56;
      case WType.listTile: return 64;
      case WType.appBar: return 56;
      case WType.card: return 160;
      case WType.row: return 60;
      case WType.column: return 200;
      case WType.stack: return 200;
      case WType.listView: return 300;
      case WType.gridView: return 300;
      default: return 120;
    }
  }

  // ── Default properties per type ───────────────────────────
  static Map<String, dynamic> _defaultProps(WType t) {
    final base = <String, dynamic>{
      // Common
      'opacity': 1.0,
      'borderRadius': 0.0,
      'elevation': 0.0,
      'padding': 8.0,
      'margin': 0.0,
    };

    switch (t) {
      case WType.container:
        return {
          ...base,
          'color': '#6C63FF',
          'borderColor': '',
          'borderWidth': 0.0,
          'gradientEnabled': false,
          'gradientStart': '#6C63FF',
          'gradientEnd': '#03DAC6',
          'gradientAngle': 'topLeft',
          'shadowEnabled': false,
          'shadowColor': '#000000',
          'shadowBlur': 8.0,
          'shadowX': 0.0,
          'shadowY': 4.0,
          'clipBehavior': 'none',
        };

      case WType.text:
        return {
          ...base,
          'text': 'Hello World',
          'fontSize': 16.0,
          'color': '#212121',
          'fontWeight': 'normal',
          'fontStyle': 'normal',
          'textAlign': 'left',
          'letterSpacing': 0.0,
          'lineHeight': 1.4,
          'maxLines': 0,
          'overflow': 'visible',
          'decoration': 'none',
          'backgroundColor': '',
        };

      case WType.image:
        return {
          ...base,
          'imageUrl': 'https://picsum.photos/seed/gax/400/300',
          'fit': 'cover',
          'borderRadius': 8.0,
          'opacity': 1.0,
          'colorFilter': '',
        };

      case WType.button:
        return {
          ...base,
          'label': 'Button',
          'style': 'elevated',  // elevated | outlined | text | filled
          'backgroundColor': '#6C63FF',
          'foregroundColor': '#FFFFFF',
          'fontSize': 14.0,
          'fontWeight': 'w600',
          'borderRadius': 8.0,
          'elevation': 2.0,
          'borderColor': '#6C63FF',
          'borderWidth': 1.5,
          'icon': '',
          'iconPosition': 'left',
        };

      case WType.iconButton:
        return {
          ...base,
          'icon': 'favorite',
          'color': '#6C63FF',
          'size': 24.0,
          'backgroundColor': '',
          'tooltip': '',
        };

      case WType.textField:
        return {
          ...base,
          'hintText': 'Enter text...',
          'labelText': 'Label',
          'helperText': '',
          'prefixIcon': '',
          'suffixIcon': '',
          'obscureText': false,
          'borderType': 'outline',   // outline | underline | none
          'fillColor': '#FFFFFF',
          'borderColor': '#CCCCCC',
          'focusColor': '#6C63FF',
          'maxLines': 1,
          'keyboardType': 'text',
        };

      case WType.card:
        return {
          ...base,
          'color': '#FFFFFF',
          'elevation': 4.0,
          'borderRadius': 12.0,
          'shadowColor': '#000000',
          'clipBehavior': 'antiAlias',
        };

      case WType.icon:
        return {
          ...base,
          'icon': 'star',
          'color': '#6C63FF',
          'size': 32.0,
          'backgroundColor': '',
        };

      case WType.switchW:
        return {
          ...base,
          'value': true,
          'activeColor': '#6C63FF',
          'inactiveThumbColor': '#BDBDBD',
          'inactiveTrackColor': '#E0E0E0',
          'label': '',
        };

      case WType.slider:
        return {
          ...base,
          'value': 0.5,
          'min': 0.0,
          'max': 1.0,
          'divisions': 0,
          'activeColor': '#6C63FF',
          'inactiveColor': '#E0E0E0',
          'label': '',
          'showLabel': false,
        };

      case WType.checkbox:
        return {
          ...base,
          'value': false,
          'activeColor': '#6C63FF',
          'label': 'Check me',
          'tristate': false,
        };

      case WType.divider:
        return {
          ...base,
          'color': '#E0E0E0',
          'thickness': 1.0,
          'indent': 0.0,
          'endIndent': 0.0,
          'vertical': false,
        };

      case WType.listTile:
        return {
          ...base,
          'title': 'List Item',
          'subtitle': 'Subtitle text',
          'leadingIcon': 'circle',
          'trailingIcon': 'chevron_right',
          'tileColor': '',
          'selectedColor': '#6C63FF',
          'dense': false,
        };

      case WType.circleAvatar:
        return {
          ...base,
          'imageUrl': '',
          'initials': 'GX',
          'backgroundColor': '#6C63FF',
          'foregroundColor': '#FFFFFF',
          'radius': 28.0,
          'fontSize': 18.0,
        };

      case WType.row:
        return {
          ...base,
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'mainAxisSize': 'max',
          'color': '',
        };

      case WType.column:
        return {
          ...base,
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'mainAxisSize': 'max',
          'color': '',
          'scrollable': false,
        };

      case WType.stack:
        return {
          ...base,
          'color': '',
          'fit': 'loose',
          'alignment': 'topLeft',
        };

      case WType.listView:
        return {
          ...base,
          'itemCount': 5,
          'spacing': 8.0,
          'horizontal': false,
          'color': '',
          'showScrollbar': false,
        };

      case WType.gridView:
        return {
          ...base,
          'crossAxisCount': 2,
          'mainAxisSpacing': 8.0,
          'crossAxisSpacing': 8.0,
          'childAspectRatio': 1.0,
          'color': '',
        };

      case WType.appBar:
        return {
          ...base,
          'title': 'App Title',
          'backgroundColor': '#6C63FF',
          'foregroundColor': '#FFFFFF',
          'elevation': 0.0,
          'centerTitle': true,
          'leadingIcon': 'menu',
          'showLeading': true,
          'showActions': false,
        };
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  String get displayName => name ?? type.name;

  WidgetNode copyWith({
    String? id, WType? type, double? x, double? y,
    double? width, double? height, bool? visible, bool? locked,
    String? name, Map<String, dynamic>? props,
    List<WidgetNode>? children, int? zIndex,
  }) {
    return WidgetNode(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x, y: y ?? this.y,
      width: width ?? this.width, height: height ?? this.height,
      visible: visible ?? this.visible, locked: locked ?? this.locked,
      name: name ?? this.name,
      props: props ?? Map.from(this.props),
      children: children ?? this.children.map((c) => c.copyWith()).toList(),
      zIndex: zIndex ?? this.zIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type.index,
    'x': x, 'y': y, 'width': width, 'height': height,
    'visible': visible, 'locked': locked, 'name': name,
    'props': props, 'zIndex': zIndex,
    'children': children.map((c) => c.toJson()).toList(),
  };

  factory WidgetNode.fromJson(Map<String, dynamic> j) {
    return WidgetNode(
      id: j['id'],
      type: WType.values[j['type'] as int],
      x: (j['x'] as num).toDouble(),
      y: (j['y'] as num).toDouble(),
      width: (j['width'] as num).toDouble(),
      height: (j['height'] as num).toDouble(),
      visible: j['visible'] as bool? ?? true,
      locked: j['locked'] as bool? ?? false,
      name: j['name'] as String?,
      props: Map<String, dynamic>.from(j['props'] ?? {}),
      zIndex: j['zIndex'] as int? ?? 0,
      children: (j['children'] as List?)
          ?.map((c) => WidgetNode.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

// ── Common icon name → IconData mapping ──────────────────────
IconData iconFromName(String name) {
  const map = <String, IconData>{
    'star': Icons.star, 'favorite': Icons.favorite,
    'home': Icons.home, 'settings': Icons.settings,
    'person': Icons.person, 'search': Icons.search,
    'add': Icons.add, 'close': Icons.close,
    'check': Icons.check, 'edit': Icons.edit,
    'delete': Icons.delete, 'share': Icons.share,
    'menu': Icons.menu, 'arrow_back': Icons.arrow_back,
    'arrow_forward': Icons.arrow_forward,
    'chevron_right': Icons.chevron_right,
    'chevron_left': Icons.chevron_left,
    'expand_more': Icons.expand_more,
    'notifications': Icons.notifications,
    'email': Icons.email, 'phone': Icons.phone,
    'location_on': Icons.location_on,
    'camera': Icons.camera_alt, 'image': Icons.image,
    'play_arrow': Icons.play_arrow, 'pause': Icons.pause,
    'circle': Icons.circle, 'info': Icons.info,
    'warning': Icons.warning, 'error': Icons.error,
    'lock': Icons.lock, 'visibility': Icons.visibility,
    'thumb_up': Icons.thumb_up, 'comment': Icons.comment,
    'send': Icons.send, 'attach_file': Icons.attach_file,
    'cloud': Icons.cloud, 'download': Icons.download,
    'upload': Icons.upload, 'refresh': Icons.refresh,
    'filter_list': Icons.filter_list, 'sort': Icons.sort,
  };
  return map[name] ?? Icons.widgets;
}

// ── Color parse helper ────────────────────────────────────────
Color parseColor(dynamic hex, {Color fallback = Colors.transparent}) {
  if (hex == null || hex.toString().isEmpty) return fallback;
  try {
    final s = hex.toString().replaceAll('#', '').trim();
    if (s.length == 6) return Color(int.parse('FF$s', radix: 16));
    if (s.length == 8) return Color(int.parse(s, radix: 16));
  } catch (_) {}
  return fallback;
}

String colorToHex(Color c) =>
    '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
