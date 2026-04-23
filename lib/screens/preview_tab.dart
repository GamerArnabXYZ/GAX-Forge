import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Preview Tab - designed UI ka live preview dikhata hai
/// User dekhi sakta hai ki actual app mein kaisa dikhega
class PreviewTab extends ConsumerStatefulWidget {
  const PreviewTab({super.key});

  @override
  ConsumerState<PreviewTab> createState() => _PreviewTabState();
}

class _PreviewTabState extends ConsumerState<PreviewTab> {
  bool _isDarkBackground = false;
  String _selectedDevice = 'Pixel 6';

  // Device presets
  static const Map<String, Map<String, double>> _devicePresets = {
    'Pixel 6': {'width': 412.0, 'height': 915.0},
    'iPhone 14': {'width': 390.0, 'height': 844.0},
    'Samsung S23': {'width': 360.0, 'height': 780.0},
  };

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);

    return Container(
      color: _isDarkBackground ? Colors.black : Colors.grey.shade200,
      child: Column(
        children: [
          // Device selector
          _buildDeviceSelector(),

          // Preview area
          Expanded(
            child: Center(
              child: _buildDeviceFrame(canvasState),
            ),
          ),
        ],
      ),
    );
  }

  /// Device selector
  Widget _buildDeviceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Device dropdown
          Expanded(
            child: DropdownButton<String>(
              value: _selectedDevice,
              isExpanded: true,
              underline: const SizedBox(),
              items: _devicePresets.keys.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDevice = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 16),

          // Background toggle
          Row(
            children: [
              const Text('Dark BG'),
              Switch(
                value: _isDarkBackground,
                onChanged: (value) {
                  setState(() {
                    _isDarkBackground = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build device frame
  Widget _buildDeviceFrame(CanvasState canvasState) {
    final deviceInfo = _devicePresets[_selectedDevice]!;
    final width = deviceInfo['width']!;
    final height = deviceInfo['height']!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Widgets preview
            ...canvasState.widgets.map((widget) {
              return _buildPreviewWidget(widget);
            }),

            // Empty state
            if (canvasState.widgets.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No widgets to preview',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build preview widget
  Widget _buildPreviewWidget(CanvasWidgetModel widget) {
    final props = widget.properties;
    final color = _colorFromHex(props['color'] ?? '#E0E0E0');

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: _buildWidgetContent(widget, color, props),
      ),
    );
  }

  /// Build widget content for preview
  Widget _buildWidgetContent(CanvasWidgetModel widget, Color color, Map<String, dynamic> props) {
    switch (widget.type) {
      case WidgetType.text:
        return Text(
          props['text'] ?? 'Text',
          style: TextStyle(
            fontSize: (props['fontSize'] ?? 16.0).toDouble(),
            fontWeight: _getFontWeight(props['fontWeight'] ?? 'normal'),
            color: _colorFromHex(props['color'] ?? '#000000'),
          ),
        );

      case WidgetType.icon:
        return Icon(
          _parseIcon(props['iconName'] ?? 'Icons.star'),
          size: (props['size'] ?? 24.0).toDouble(),
          color: _colorFromHex(props['color'] ?? '#757575'),
        );

      case WidgetType.image:
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey),
          ),
        );

      case WidgetType.elevatedButton:
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: _colorFromHex(props['buttonColor'] ?? '#6750A4'),
            foregroundColor: _colorFromHex(props['textColor'] ?? '#FFFFFF'),
          ),
          child: Text(props['label'] ?? 'Button'),
        );

      case WidgetType.textButton:
        return TextButton(
          onPressed: () {},
          child: Text(props['label'] ?? 'Text Button'),
        );

      case WidgetType.outlinedButton:
        return OutlinedButton(
          onPressed: () {},
          child: Text(props['label'] ?? 'Outlined'),
        );

      case WidgetType.iconButton:
        return IconButton(
          icon: Icon(_parseIcon(props['iconName'] ?? 'Icons.add')),
          onPressed: () {},
          color: _colorFromHex(props['color'] ?? '#757575'),
        );

      case WidgetType.card:
        return Card(
          elevation: (props['elevation'] ?? 2.0).toDouble(),
          color: _colorFromHex(props['color'] ?? '#FFFFFF'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((props['borderRadius'] ?? 12.0).toDouble()),
          ),
          child: const Center(child: Text('Card')),
        );

      case WidgetType.containerDecorated:
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular((props['borderRadius'] ?? 0.0).toDouble()),
            border: Border.all(
              color: _colorFromHex(props['borderColor'] ?? '#000000'),
              width: (props['borderWidth'] ?? 0.0).toDouble(),
            ),
          ),
        );

      case WidgetType.circleAvatar:
        return CircleAvatar(
          radius: (props['radius'] ?? 20.0).toDouble(),
          backgroundColor: _colorFromHex(props['backgroundColor'] ?? '#2196F3'),
          foregroundColor: _colorFromHex(props['foregroundColor'] ?? '#FFFFFF'),
          child: Text(props['text'] ?? 'A'),
        );

      case WidgetType.chip:
        return Chip(
          label: Text(props['label'] ?? 'Chip'),
          backgroundColor: _colorFromHex(props['backgroundColor'] ?? '#E0E0E0'),
        );

      case WidgetType.badge:
        return Badge(
          label: Text(props['label'] ?? '1'),
          backgroundColor: _colorFromHex(props['backgroundColor'] ?? '#F44336'),
          child: const Icon(Icons.notifications),
        );

      case WidgetType.linearProgressIndicator:
        return LinearProgressIndicator(
          value: (props['value'] ?? 0.5).toDouble(),
          color: _colorFromHex(props['color'] ?? '#6750A4'),
          backgroundColor: _colorFromHex(props['backgroundColor'] ?? '#E0E0E0'),
        );

      case WidgetType.circularProgressIndicator:
        return SizedBox(
          width: (props['size'] ?? 40.0).toDouble(),
          height: (props['size'] ?? 40.0).toDouble(),
          child: CircularProgressIndicator(
            color: _colorFromHex(props['color'] ?? '#6750A4'),
          ),
        );

      case WidgetType.switchWidget:
        return Switch(
          value: (props['value'] ?? false) as bool,
          activeColor: _colorFromHex(props['activeColor'] ?? '#6750A4'),
          onChanged: (_) {},
        );

      case WidgetType.checkbox:
        return Checkbox(
          value: (props['value'] ?? false) as bool,
          activeColor: _colorFromHex(props['activeColor'] ?? '#6750A4'),
          onChanged: (_) {},
        );

      case WidgetType.divider:
        return Divider(
          thickness: (props['thickness'] ?? 1.0).toDouble(),
          color: _colorFromHex(props['color'] ?? '#E0E0E0'),
        );

      case WidgetType.listTile:
        return ListTile(
          title: Text(props['title'] ?? 'ListTile'),
          subtitle: props['subtitle'] != null && props['subtitle'].toString().isNotEmpty
              ? Text(props['subtitle'].toString())
              : null,
          leading: Icon(_parseIcon(props['leadingIcon'] ?? 'Icons.list')),
          trailing: Icon(_parseIcon(props['trailingIcon'] ?? 'Icons.arrow_forward_ios')),
        );

      case WidgetType.appBar:
        return Container(
          height: 56,
          color: _colorFromHex(props['backgroundColor'] ?? '#6750A4'),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                props['title'] ?? 'AppBar',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

      case WidgetType.row:
      case WidgetType.column:
      case WidgetType.stack:
      case WidgetType.wrap:
      case WidgetType.padding:
      case WidgetType.center:
      case WidgetType.expanded:
      case WidgetType.flexible:
      case WidgetType.scaffold:
      case WidgetType.radio:
      case WidgetType.container:
        // Complex layouts - just show container
        return Container(
          color: color,
          child: Center(
            child: Text(
              widget.type.displayName,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        );

      default:
        return Container(
          color: color,
          child: Center(
            child: Text(
              widget.type.displayName,
              style: TextStyle(fontSize: 10, color: _getContrastColor(color)),
            ),
          ),
        );
    }
  }

  /// Parse color from hex
  Color _colorFromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    return Colors.grey;
  }

  /// Parse icon from string
  IconData _parseIcon(String iconName) {
    final iconMap = {
      'Icons.star': Icons.star,
      'Icons.favorite': Icons.favorite,
      'Icons.home': Icons.home,
      'Icons.settings': Icons.settings,
      'Icons.person': Icons.person,
      'Icons.add': Icons.add,
      'Icons.edit': Icons.edit,
      'Icons.delete': Icons.delete,
      'Icons.search': Icons.search,
      'Icons.menu': Icons.menu,
      'Icons.list': Icons.list,
      'Icons.arrow_forward_ios': Icons.arrow_forward_ios,
      'Icons.notifications': Icons.notifications,
    };
    return iconMap[iconName] ?? Icons.star;
  }

  /// Get font weight from string
  FontWeight _getFontWeight(String weight) {
    switch (weight.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  /// Get contrast color
  Color _getContrastColor(Color bgColor) {
    final luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
