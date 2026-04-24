// lib/screens/widgets/panels/properties_panel.dart
// GAX Forge - Widget Properties Editor Panel

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/app_models.dart';
import '../../../providers/project_provider.dart';

class PropertiesPanel extends ConsumerWidget {
  final String projectId;
  const PropertiesPanel({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.watch(editorProvider(projectId));
    final notifier = ref.read(editorProvider(projectId).notifier);
    final selected = editor.selectedWidget;

    if (selected == null) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 360),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.tune_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  selected.type,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Size info
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${selected.width.round()} × ${selected.height.round()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => notifier.selectWidget(null),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Properties
          Flexible(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shrinkWrap: true,
              children: _buildProperties(context, selected, notifier),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProperties(
    BuildContext context,
    WidgetProperty w,
    EditorNotifier notifier,
  ) {
    final props = <Widget>[];

    // ── Size Controls (always shown) ───────────
    props.add(_SectionLabel('Dimensions'));
    props.add(Row(
      children: [
        Expanded(
          child: _NumField(
            label: 'Width',
            value: w.width,
            onChanged: (v) => notifier.resizeWidget(w.id, v, w.height),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NumField(
            label: 'Height',
            value: w.height,
            onChanged: (v) => notifier.resizeWidget(w.id, w.width, v),
          ),
        ),
      ],
    ));
    props.add(_SectionLabel('Position'));
    props.add(Row(
      children: [
        Expanded(
          child: _NumField(
            label: 'X',
            value: w.x,
            onChanged: (v) {
              notifier.moveWidget(w.id, v - w.x, 0);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NumField(
            label: 'Y',
            value: w.y,
            onChanged: (v) {
              notifier.moveWidget(w.id, 0, v - w.y);
            },
          ),
        ),
      ],
    ));

    // ── Type-specific Props ────────────────────
    final p = w.props;

    void setProp(String key, dynamic val) =>
        notifier.updateWidgetProp(w.id, key, val);

    // Text content
    if (p.containsKey('text')) {
      props.add(_SectionLabel('Content'));
      props.add(_TextField2(
        label: 'Text',
        value: p['text'] as String,
        onChanged: (v) => setProp('text', v),
      ));
    }
    if (p.containsKey('hintText')) {
      props.add(_TextField2(
        label: 'Hint Text',
        value: p['hintText'] as String,
        onChanged: (v) => setProp('hintText', v),
      ));
    }
    if (p.containsKey('labelText')) {
      props.add(_TextField2(
        label: 'Label Text',
        value: p['labelText'] as String,
        onChanged: (v) => setProp('labelText', v),
      ));
    }
    if (p.containsKey('title')) {
      props.add(_TextField2(
        label: 'Title',
        value: p['title'] as String,
        onChanged: (v) => setProp('title', v),
      ));
    }
    if (p.containsKey('subtitle')) {
      props.add(_TextField2(
        label: 'Subtitle',
        value: p['subtitle'] as String,
        onChanged: (v) => setProp('subtitle', v),
      ));
    }

    // Typography
    if (p.containsKey('fontSize')) {
      props.add(_SectionLabel('Typography'));
      props.add(_SliderRow(
        label: 'Font Size',
        value: (p['fontSize'] as num).toDouble(),
        min: 8,
        max: 72,
        onChanged: (v) => setProp('fontSize', v),
        showValue: true,
      ));
    }
    if (p.containsKey('fontWeight')) {
      props.add(_SegmentedRow(
        label: 'Weight',
        options: const ['normal', 'bold'],
        labels: const ['Normal', 'Bold'],
        selected: p['fontWeight'] as String,
        onChanged: (v) => setProp('fontWeight', v),
      ));
    }
    if (p.containsKey('textAlign')) {
      props.add(_SegmentedRow(
        label: 'Align',
        options: const ['left', 'center', 'right'],
        labels: const ['Left', 'Center', 'Right'],
        selected: p['textAlign'] as String,
        onChanged: (v) => setProp('textAlign', v),
      ));
    }

    // Colors
    if (p.containsKey('color')) {
      props.add(_SectionLabel('Colors'));
      props.add(_ColorRow(
        context: context,
        label: 'Color',
        value: Color(p['color'] as int),
        onChanged: (c) => setProp('color', c.value),
      ));
    }
    if (p.containsKey('textColor')) {
      props.add(_ColorRow(
        context: context,
        label: 'Text Color',
        value: Color(p['textColor'] as int),
        onChanged: (c) => setProp('textColor', c.value),
      ));
    }
    if (p.containsKey('backgroundColor')) {
      props.add(_ColorRow(
        context: context,
        label: 'Background',
        value: Color(p['backgroundColor'] as int),
        onChanged: (c) => setProp('backgroundColor', c.value),
      ));
    }
    if (p.containsKey('activeColor')) {
      props.add(_ColorRow(
        context: context,
        label: 'Active Color',
        value: Color(p['activeColor'] as int),
        onChanged: (c) => setProp('activeColor', c.value),
      ));
    }

    // Geometry
    if (p.containsKey('borderRadius')) {
      props.add(_SectionLabel('Shape'));
      props.add(_SliderRow(
        label: 'Border Radius',
        value: (p['borderRadius'] as num).toDouble(),
        min: 0,
        max: 64,
        onChanged: (v) => setProp('borderRadius', v),
        showValue: true,
      ));
    }
    if (p.containsKey('elevation')) {
      props.add(_SliderRow(
        label: 'Elevation',
        value: (p['elevation'] as num).toDouble(),
        min: 0,
        max: 24,
        onChanged: (v) => setProp('elevation', v),
        showValue: true,
      ));
    }
    if (p.containsKey('padding')) {
      props.add(_SliderRow(
        label: 'Padding',
        value: (p['padding'] as num).toDouble(),
        min: 0,
        max: 64,
        onChanged: (v) => setProp('padding', v),
        showValue: true,
      ));
    }
    if (p.containsKey('opacity')) {
      props.add(_SliderRow(
        label: 'Opacity',
        value: (p['opacity'] as num).toDouble(),
        min: 0,
        max: 1,
        onChanged: (v) => setProp('opacity', v),
        showValue: true,
      ));
    }

    // Border
    if (p.containsKey('hasBorder')) {
      props.add(_SectionLabel('Border'));
      props.add(SwitchListTile(
        title: const Text('Show Border'),
        value: p['hasBorder'] as bool,
        onChanged: (v) => setProp('hasBorder', v),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ));
    }

    // Toggle values
    if (p.containsKey('value') && w.type == 'Switch') {
      props.add(SwitchListTile(
        title: const Text('Value'),
        value: p['value'] as bool,
        onChanged: (v) => setProp('value', v),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ));
    }
    if (p.containsKey('value') && w.type == 'Slider') {
      props.add(_SliderRow(
        label: 'Value',
        value: (p['value'] as num).toDouble(),
        min: (p['min'] as num).toDouble(),
        max: (p['max'] as num).toDouble(),
        onChanged: (v) => setProp('value', v),
        showValue: true,
      ));
    }
    if (p.containsKey('value') && w.type == 'LinearProgressIndicator') {
      props.add(_SliderRow(
        label: 'Progress',
        value: (p['value'] as num).toDouble(),
        min: 0,
        max: 1,
        onChanged: (v) => setProp('value', v),
        showValue: true,
      ));
    }

    if (p.containsKey('centerTitle')) {
      props.add(SwitchListTile(
        title: const Text('Center Title'),
        value: p['centerTitle'] as bool,
        onChanged: (v) => setProp('centerTitle', v),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ));
    }

    if (p.containsKey('mini') && w.type == 'FloatingActionButton') {
      props.add(SwitchListTile(
        title: const Text('Mini FAB'),
        value: p['mini'] as bool,
        onChanged: (v) => setProp('mini', v),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ));
    }

    props.add(const SizedBox(height: 24));
    return props;
  }
}

// ── Property Helper Widgets ────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NumField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _NumField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<_NumField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.round().toString());
  }

  @override
  void didUpdateWidget(_NumField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _ctrl.text = widget.value.round().toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      decoration: InputDecoration(
        labelText: widget.label,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      keyboardType: TextInputType.number,
      onSubmitted: (v) {
        final d = double.tryParse(v);
        if (d != null) widget.onChanged(d);
      },
    );
  }
}

class _TextField2 extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onChanged;

  const _TextField2({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_TextField2> createState() => _TextField2State();
}

class _TextField2State extends State<_TextField2> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final bool showValue;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        if (showValue)
          SizedBox(
            width: 36,
            child: Text(
              value < 2
                  ? value.toStringAsFixed(2)
                  : value.round().toString(),
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> labels;
  final String selected;
  final Function(String) onChanged;

  const _SegmentedRow({
    required this.label,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: SegmentedButton<String>(
              segments: List.generate(
                options.length,
                (i) => ButtonSegment(value: options[i], label: Text(labels[i])),
              ),
              selected: {selected},
              onSelectionChanged: (s) => onChanged(s.first),
              style: const ButtonStyle(
                  visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final BuildContext context;
  final String label;
  final Color value;
  final Function(Color) onChanged;

  const _ColorRow({
    required this.context,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          GestureDetector(
            onTap: () => _pickColor(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: value,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '#${value.value.toRadixString(16).toUpperCase().substring(2)}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  void _pickColor(BuildContext ctx) {
    Color temp = value;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Pick $label'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: value,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onChanged(temp);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
