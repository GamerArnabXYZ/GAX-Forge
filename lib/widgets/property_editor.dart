import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Property Editor - selected widget ki properties edit karne ke liye
/// Dynamic form based on widget type
class PropertyEditor extends ConsumerWidget {
  final CanvasWidgetModel widgetModel;

  const PropertyEditor({super.key, required this.widgetModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget type header
          _buildHeader(context),
          const SizedBox(height: 16),

          // Size properties
          _buildSection(context, 'Size', Icons.straighten, [
            _buildSizeProperty(context, ref, 'Width', 'width', 20, 500),
            _buildSizeProperty(context, ref, 'Height', 'height', 20, 500),
          ]),
          const SizedBox(height: 16),

          // Position properties
          _buildSection(context, 'Position', Icons.open_with, [
            _buildPositionProperty(context, ref, 'X', 'positionX'),
            _buildPositionProperty(context, ref, 'Y', 'positionY'),
          ]),
          const SizedBox(height: 16),

          // Type-specific properties
          _buildTypeSpecificProperties(context, ref),
        ],
      ),
    );
  }

  /// Build header with widget type
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForType(widgetModel.type),
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widgetModel.type.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ID: ${widgetModel.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section with title
  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  /// Build size property slider
  Widget _buildSizeProperty(BuildContext context, WidgetRef ref, String label, String property, double min, double max) {
    final value = (widgetModel.properties[property] ?? 100.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: ((max - min) / 10).round(),
              onChanged: (newValue) {
                ref.read(canvasProvider.notifier).updateWidgetProperty(widgetModel.id, property, newValue);
              },
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '${value.toInt()}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build position property
  Widget _buildPositionProperty(BuildContext context, WidgetRef ref, String label, String property) {
    final value = property == 'positionX'
        ? widgetModel.position.dx
        : widgetModel.position.dy;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(0, 500),
              min: 0,
              max: 500,
              onChanged: (newValue) {
                if (property == 'positionX') {
                  ref.read(canvasProvider.notifier).updateWidgetPosition(
                    widgetModel.id,
                    Offset(newValue, widgetModel.position.dy),
                  );
                } else {
                  ref.read(canvasProvider.notifier).updateWidgetPosition(
                    widgetModel.id,
                    Offset(widgetModel.position.dx, newValue),
                  );
                }
              },
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '${value.toInt()}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build type-specific properties
  Widget _buildTypeSpecificProperties(BuildContext context, WidgetRef ref) {
    switch (widgetModel.type) {
      case WidgetType.text:
        return _buildTextProperties(context, ref);
      case WidgetType.container:
      case WidgetType.containerDecorated:
        return _buildContainerProperties(context, ref);
      case WidgetType.icon:
        return _buildIconProperties(context, ref);
      case WidgetType.image:
        return _buildImageProperties(context, ref);
      case WidgetType.elevatedButton:
      case WidgetType.textButton:
      case WidgetType.outlinedButton:
        return _buildButtonProperties(context, ref);
      case WidgetType.card:
        return _buildCardProperties(context, ref);
      case WidgetType.circleAvatar:
        return _buildCircleAvatarProperties(context, ref);
      case WidgetType.chip:
        return _buildChipProperties(context, ref);
      default:
        return _buildGenericProperties(context, ref);
    }
  }

  /// Text properties
  Widget _buildTextProperties(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, 'Text Properties', Icons.text_fields, [
          _buildTextFieldProperty(context, ref, 'Text', 'text'),
          _buildSliderProperty(context, ref, 'Font Size', 'fontSize', 8, 72, 16),
          _buildDropdownProperty(context, ref, 'Font Weight', 'fontWeight', [
            'normal', 'bold', 'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700', 'w800', 'w900',
          ]),
          _buildColorProperty(context, ref, 'Color', 'color'),
        ]),
      ],
    );
  }

  /// Container properties
  Widget _buildContainerProperties(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, 'Container Properties', Icons.crop_square, [
          _buildColorProperty(context, ref, 'Background', 'color'),
          if (widgetModel.type == WidgetType.containerDecorated) ...[
            _buildSliderProperty(context, ref, 'Border Radius', 'borderRadius', 0, 50, 12),
            _buildColorProperty(context, ref, 'Border Color', 'borderColor'),
            _buildSliderProperty(context, ref, 'Border Width', 'borderWidth', 0, 10, 1),
          ],
        ]),
      ],
    );
  }

  /// Icon properties
  Widget _buildIconProperties(BuildContext context, WidgetRef ref) {
    return _buildSection(context, 'Icon Properties', Icons.star, [
      _buildDropdownProperty(context, ref, 'Icon', 'iconName', [
        'Icons.star', 'Icons.favorite', 'Icons.home', 'Icons.settings',
        'Icons.person', 'Icons.add', 'Icons.edit', 'Icons.delete',
        'Icons.search', 'Icons.menu', 'Icons.list', 'Icons.notifications',
      ]),
      _buildSliderProperty(context, ref, 'Size', 'size', 12, 96, 24),
      _buildColorProperty(context, ref, 'Color', 'color'),
    ]);
  }

  /// Image properties
  Widget _buildImageProperties(BuildContext context, WidgetRef ref) {
    return _buildSection(context, 'Image Properties', Icons.image, [
      _buildTextFieldProperty(context, ref, 'Image URL', 'imageUrl'),
      _buildDropdownProperty(context, ref, 'Fit', 'fit', ['cover', 'contain', 'fill', 'none']),
    ]);
  }

  /// Button properties
  Widget _buildButtonProperties(BuildContext context, WidgetRef ref) {
    return _buildSection(context, 'Button Properties', Icons.smart_button, [
      _buildTextFieldProperty(context, ref, 'Label', 'label'),
      _buildColorProperty(context, ref, 'Button Color', 'buttonColor'),
      _buildColorProperty(context, ref, 'Text Color', 'textColor'),
    ]);
  }

  /// Card properties
  Widget _buildCardProperties(BuildContext context, WidgetRef ref) {
    return _buildSection(context, 'Card Properties', Icons.credit_card, [
      _buildSliderProperty(context, ref, 'Elevation', 'elevation', 0, 10, 2),
      _buildColorProperty(context, ref, 'Color', 'color'),
      _buildSliderProperty(context, ref, 'Border Radius', 'borderRadius', 0, 24, 12),
    ]);
  }

  /// CircleAvatar properties
  Widget _buildCircleAvatarProperties(BuildContext context, WidgetRef ref) {
    return _buildSection(context, 'Avatar Properties', Icons.account_circle, [
      _buildSliderProperty(context, ref, 'Radius', 'radius', 10, 50, 20),
      _buildColorProperty(context, ref, 'Background', 'backgroundColor'),
      _buildColorProperty(context, ref, 'Foreground', 'foregroundColor'),
      _buildTextFieldProperty(context, ref, 'Text', 'text'),
    ]);
  }

  /// Chip properties
  Widget _buildChipProperties(BuildContext context, WidgetRef ref) {
    return _buildSection(context, 'Chip Properties', Icons.label, [
      _buildTextFieldProperty(context, ref, 'Label', 'label'),
      _buildColorProperty(context, ref, 'Background', 'backgroundColor'),
    ]);
  }

  /// Generic properties
  Widget _buildGenericProperties(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No additional properties for ${widgetModel.type.displayName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Text field property
  Widget _buildTextFieldProperty(BuildContext context, WidgetRef ref, String label, String property) {
    final value = widgetModel.properties[property]?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
        ),
        onChanged: (newValue) {
          ref.read(canvasProvider.notifier).updateWidgetProperty(widgetModel.id, property, newValue);
        },
      ),
    );
  }

  /// Slider property
  Widget _buildSliderProperty(BuildContext context, WidgetRef ref, String label, String property, double min, double max, double defaultValue) {
    final value = (widgetModel.properties[property] ?? defaultValue).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: (newValue) {
                ref.read(canvasProvider.notifier).updateWidgetProperty(widgetModel.id, property, newValue);
              },
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '${value.toInt()}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dropdown property
  Widget _buildDropdownProperty(BuildContext context, WidgetRef ref, String label, String property, List<String> options) {
    final value = widgetModel.properties[property]?.toString() ?? options.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              underline: const SizedBox(),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  ref.read(canvasProvider.notifier).updateWidgetProperty(widgetModel.id, property, newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Color property with color picker
  Widget _buildColorProperty(BuildContext context, WidgetRef ref, String label, String property) {
    final hexColor = widgetModel.properties[property]?.toString() ?? '#000000';
    final color = _colorFromHex(hexColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          GestureDetector(
            onTap: () => _showColorPicker(context, ref, property, color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hexColor,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show color picker dialog
  void _showColorPicker(BuildContext context, WidgetRef ref, String property, Color currentColor) {
    Color selectedColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final hex = '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
              ref.read(canvasProvider.notifier).updateWidgetProperty(widgetModel.id, property, hex);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  /// Get icon for widget type
  IconData _getIconForType(WidgetType type) {
    switch (type) {
      case WidgetType.container:
        return Icons.crop_square;
      case WidgetType.text:
        return Icons.text_fields;
      case WidgetType.icon:
        return Icons.star;
      case WidgetType.image:
        return Icons.image;
      case WidgetType.elevatedButton:
        return Icons.smart_button;
      default:
        return Icons.widgets;
    }
  }

  /// Parse color from hex
  Color _colorFromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    return Colors.black;
  }
}
