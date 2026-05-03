// lib/screens/widgets/panels/properties_panel.dart
// GAX Forge - Full Properties Panel (max properties per widget)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/app_models.dart';
import '../../../providers/project_provider.dart';

class PropertiesPanel extends ConsumerStatefulWidget {
  final String projectId;
  const PropertiesPanel({super.key, required this.projectId});

  @override
  ConsumerState<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends ConsumerState<PropertiesPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(editorProvider(widget.projectId));
    final notifier = ref.read(editorProvider(widget.projectId).notifier);
    final selected = editor.selectedWidget;
    final scheme = Theme.of(context).colorScheme;

    if (selected == null) {
      return Container(
        height: 60,
        color: scheme.surfaceContainerLow,
        child: Center(child: Text('Select a widget to edit properties',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13))),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(margin: const EdgeInsets.only(top: 10, bottom: 2), width: 36, height: 4,
            decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.tune_rounded, size: 16, color: scheme.onPrimaryContainer)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(selected.customName ?? selected.type,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('${selected.width.round()} × ${selected.height.round()}  •  z:${selected.zIndex}',
                  style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
              ])),
              // Quick actions
              IconButton(icon: const Icon(Icons.flip_to_front_rounded, size: 18),
                tooltip: 'Bring to Front', visualDensity: VisualDensity.compact,
                onPressed: () => notifier.bringToFront(selected.id)),
              IconButton(icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'Duplicate', visualDensity: VisualDensity.compact,
                onPressed: () => notifier.duplicateWidget(selected.id)),
              IconButton(icon: Icon(Icons.delete_rounded, size: 18, color: scheme.error),
                tooltip: 'Delete', visualDensity: VisualDensity.compact,
                onPressed: () { notifier.deleteWidget(selected.id); }),
              IconButton(icon: const Icon(Icons.close_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () => notifier.selectWidget(null)),
            ]),
          ),
          // Tabs
          TabBar(
            controller: _tabCtrl,
            isScrollable: false,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            tabs: const [
              Tab(icon: Icon(Icons.tune_rounded, size: 16), text: 'Props'),
              Tab(icon: Icon(Icons.straighten_rounded, size: 16), text: 'Layout'),
              Tab(icon: Icon(Icons.animation_rounded, size: 16), text: 'Style'),
            ],
          ),
          // Content
          Flexible(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _PropsTab(projectId: widget.projectId, widget_: selected, notifier: notifier),
                _LayoutTab(widget_: selected, notifier: notifier),
                _StyleTab(context: context, widget_: selected, notifier: notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// PROPS TAB (type-specific properties)
// ══════════════════════════════════════════════
class _PropsTab extends StatelessWidget {
  final String projectId;
  final WidgetProperty widget_;
  final EditorNotifier notifier;
  const _PropsTab({required this.projectId, required this.widget_, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      shrinkWrap: true,
      children: _buildTypeProps(context),
    );
  }

  void _set(String key, dynamic val) => notifier.updateWidgetProp(widget_.id, key, val);
  dynamic _get(String key, [dynamic fb]) => widget_.props[key] ?? fb;
  double _dbl(String key, [double fb = 0]) => ((_get(key, fb)) as num).toDouble();
  String _str(String key, [String fb = '']) => (_get(key, fb) as String?) ?? fb;
  bool _bln(String key, [bool fb = false]) => (_get(key, fb) as bool?) ?? fb;
  int _num(String key, [int fb = 0]) => (_get(key, fb) as num?)?.toInt() ?? fb;

  List<Widget> _buildTypeProps(BuildContext context) {
    final type = widget_.type;
    final items = <Widget>[];

    // ── Text content fields ──
    if (_hasKey('text')) {
      items.add(_Section('Content'));
      items.add(_TField('Text', _str('text'), (v) => _set('text', v), maxLines: 3));
    }
    if (_hasKey('hintText')) items.add(_TField('Hint Text', _str('hintText'), (v) => _set('hintText', v)));
    if (_hasKey('labelText')) items.add(_TField('Label Text', _str('labelText'), (v) => _set('labelText', v)));
    if (_hasKey('title')) items.add(_TField('Title', _str('title'), (v) => _set('title', v)));
    if (_hasKey('subtitle')) items.add(_TField('Subtitle', _str('subtitle'), (v) => _set('subtitle', v)));
    if (_hasKey('message')) items.add(_TField('Message', _str('message'), (v) => _set('message', v)));
    if (_hasKey('helperText')) items.add(_TField('Helper Text', _str('helperText'), (v) => _set('helperText', v)));
    if (_hasKey('errorText')) items.add(_TField('Error Text', _str('errorText'), (v) => _set('errorText', v)));
    if (_hasKey('actionLabel')) items.add(_TField('Action Label', _str('actionLabel'), (v) => _set('actionLabel', v)));
    if (_hasKey('cancelText')) items.add(_TField('Cancel Text', _str('cancelText'), (v) => _set('cancelText', v)));
    if (_hasKey('confirmText')) items.add(_TField('Confirm Text', _str('confirmText'), (v) => _set('confirmText', v)));

    // ── Typography ──
    if (_hasKey('fontSize')) {
      items.add(_Section('Typography'));
      items.add(_SliderRow('Font Size', _dbl('fontSize', 16), 8, 72, (v) => _set('fontSize', v)));
      if (_hasKey('fontWeight')) {
        items.add(_DropRow('Weight', _str('fontWeight', 'normal'),
          const ['normal', 'w300', 'w500', 'bold', 'w600', 'w800'],
          const ['Normal', 'Light', 'Medium', 'Bold', 'SemiBold', 'ExtraBold'],
          (v) => _set('fontWeight', v)));
      }
      if (_hasKey('fontStyle')) {
        items.add(_SegRow('Style', _str('fontStyle', 'normal'),
          const ['normal', 'italic'], const ['Normal', 'Italic'],
          (v) => _set('fontStyle', v)));
      }
      if (_hasKey('textAlign')) {
        items.add(_SegRow('Align', _str('textAlign', 'left'),
          const ['left', 'center', 'right', 'justify'],
          const ['L', 'C', 'R', 'J'],
          (v) => _set('textAlign', v)));
      }
      if (_hasKey('letterSpacing')) items.add(_SliderRow('Letter Spacing', _dbl('letterSpacing'), -4, 16, (v) => _set('letterSpacing', v)));
      if (_hasKey('lineHeight')) items.add(_SliderRow('Line Height', _dbl('lineHeight', 1), 0.8, 3.0, (v) => _set('lineHeight', v)));
      if (_hasKey('decoration')) {
        items.add(_DropRow('Decoration', _str('decoration', 'none'),
          const ['none', 'underline', 'lineThrough', 'overline'],
          const ['None', 'Underline', 'Strikethrough', 'Overline'],
          (v) => _set('decoration', v)));
      }
      if (_hasKey('maxLines')) {
        items.add(_NumRow('Max Lines', _num('maxLines'), 0, 20, (v) => _set('maxLines', v),
            hint: '0 = unlimited'));
      }
      if (_hasKey('overflow')) {
        items.add(_DropRow('Overflow', _str('overflow', 'ellipsis'),
          const ['ellipsis', 'clip', 'fade', 'visible'],
          const ['Ellipsis', 'Clip', 'Fade', 'Visible'],
          (v) => _set('overflow', v)));
      }
    }

    // ── Icon ──
    if (type == 'Icon' || _hasKey('iconCode')) {
      if (type == 'Icon') items.add(_Section('Icon'));
      if (_hasKey('size') && type == 'Icon') items.add(_SliderRow('Size', _dbl('size', 32), 12, 96, (v) => _set('size', v)));
    }

    // ── Switch / Checkbox / Slider specific ──
    if (type == 'Switch') {
      items.add(_Section('Switch'));
      items.add(_BoolRow('Value', _bln('value', true), (v) => _set('value', v)));
      items.add(_DropRow('Label Position', _str('labelPosition', 'right'),
        const ['left', 'right'], const ['Left', 'Right'], (v) => _set('labelPosition', v)));
    }
    if (type == 'Checkbox') {
      items.add(_Section('Checkbox'));
      items.add(_BoolRow('Checked', _bln('value', true), (v) => _set('value', v)));
      items.add(_DropRow('Shape', _str('shape', 'square'),
        const ['square', 'circle'], const ['Square', 'Circle'], (v) => _set('shape', v)));
      items.add(_BoolRow('Tristate', _bln('tristate'), (v) => _set('tristate', v)));
    }
    if (type == 'Slider') {
      items.add(_Section('Slider'));
      items.add(_SliderRow('Value', _dbl('value', 0.5), _dbl('min'), _dbl('max', 1), (v) => _set('value', v)));
      items.add(_NumRow('Divisions', _num('divisions'), 0, 100, (v) => _set('divisions', v)));
      items.add(_BoolRow('Show Label', _bln('showLabel', true), (v) => _set('showLabel', v)));
    }
    if (type == 'RangeSlider') {
      items.add(_Section('Range'));
      items.add(_SliderRow('Start', _dbl('startValue', 0.2), 0, 1, (v) => _set('startValue', v)));
      items.add(_SliderRow('End', _dbl('endValue', 0.8), 0, 1, (v) => _set('endValue', v)));
    }

    // ── Progress ──
    if (type == 'LinearProgressIndicator' || type == 'CircularProgressIndicator') {
      items.add(_Section('Progress'));
      items.add(_BoolRow('Indeterminate', _bln('indeterminate'), (v) => _set('indeterminate', v)));
      if (!_bln('indeterminate')) items.add(_SliderRow('Value', _dbl('value', 0.6), 0, 1, (v) => _set('value', v)));
      if (type == 'LinearProgressIndicator') {
        items.add(_SliderRow('Min Height', _dbl('minHeight', 4), 2, 24, (v) => _set('minHeight', v)));
        items.add(_BoolRow('Show % Label', _bln('valueLabel'), (v) => _set('valueLabel', v)));
      }
      if (type == 'CircularProgressIndicator') {
        items.add(_SliderRow('Stroke Width', _dbl('strokeWidth', 4), 1, 16, (v) => _set('strokeWidth', v)));
        items.add(_DropRow('Stroke Cap', _str('strokeCap', 'round'),
          const ['round', 'butt'], const ['Round', 'Flat'], (v) => _set('strokeCap', v)));
      }
    }

    // ── AppBar ──
    if (type == 'AppBar') {
      items.add(_Section('App Bar'));
      items.add(_BoolRow('Center Title', _bln('centerTitle', true), (v) => _set('centerTitle', v)));
      items.add(_DropRow('Leading', _str('leading', 'menu'),
        const ['menu', 'back', 'none'], const ['Menu', 'Back', 'None'],
        (v) => _set('leading', v)));
      items.add(_NumRow('Actions', _num('actions', 1), 0, 3, (v) => _set('actions', v)));
    }

    // ── Bottom Nav ──
    if (type == 'BottomNavigationBar') {
      items.add(_Section('Navigation'));
      items.add(_NumRow('Item Count', _num('itemCount', 3), 2, 5, (v) => _set('itemCount', v)));
      items.add(_NumRow('Active Index', _num('currentIndex'), 0, _num('itemCount', 3) - 1, (v) => _set('currentIndex', v)));
      items.add(_DropRow('Type', _str('type', 'fixed'),
        const ['fixed', 'shifting'], const ['Fixed', 'Shifting'],
        (v) => _set('type', v)));
      items.add(_BoolRow('Show Labels', _bln('showLabels', true), (v) => _set('showLabels', v)));
      for (int i = 1; i <= _num('itemCount', 3); i++) {
        items.add(_TField('Item $i Label', _str('item$i', 'Item $i'), (v) => _set('item$i', v)));
      }
    }

    // ── Tab Bar ──
    if (type == 'TabBar') {
      items.add(_Section('Tabs'));
      items.add(_NumRow('Tab Count', _num('tabCount', 3), 2, 5, (v) => _set('tabCount', v)));
      for (int i = 1; i <= _num('tabCount', 3); i++) {
        items.add(_TField('Tab $i', _str('tab$i', 'Tab $i'), (v) => _set('tab$i', v)));
      }
      items.add(_BoolRow('Scrollable', _bln('isScrollable'), (v) => _set('isScrollable', v)));
    }

    // ── NavigationDrawer ──
    if (type == 'NavigationDrawer') {
      items.add(_Section('Drawer'));
      items.add(_BoolRow('Show Header', _bln('showHeader', true), (v) => _set('showHeader', v)));
      items.add(_NumRow('Item Count', _num('itemCount', 3), 1, 5, (v) => _set('itemCount', v)));
      for (int i = 1; i <= _num('itemCount', 3); i++) {
        items.add(_TField('Item $i', _str('item$i', 'Item $i'), (v) => _set('item$i', v)));
      }
    }

    // ── FAB ──
    if (type == 'FloatingActionButton') {
      items.add(_Section('FAB'));
      items.add(_BoolRow('Extended', _bln('extended'), (v) => _set('extended', v)));
      if (_bln('extended')) items.add(_TField('Label', _str('label', 'Create'), (v) => _set('label', v)));
      items.add(_BoolRow('Mini', _bln('mini'), (v) => _set('mini', v)));
    }

    // ── Chip ──
    if (type == 'Chip') {
      items.add(_Section('Chip'));
      items.add(_BoolRow('Show Avatar', _bln('avatar'), (v) => _set('avatar', v)));
      if (_bln('avatar')) items.add(_TField('Avatar Text', _str('avatarText', 'A'), (v) => _set('avatarText', v)));
      items.add(_BoolRow('Selected', _bln('selected'), (v) => _set('selected', v)));
    }

    // ── Card ──
    if (type == 'Card') {
      items.add(_Section('Card'));
      items.add(_DropRow('Variant', _str('variant', 'elevated'),
        const ['elevated', 'outlined', 'flat'],
        const ['Elevated', 'Outlined', 'Flat'],
        (v) => _set('variant', v)));
    }

    // ── TextField ──
    if (type == 'TextField') {
      items.add(_Section('Input'));
      items.add(_DropRow('Border Style', _str('borderStyle', 'outline'),
        const ['outline', 'underline', 'none'],
        const ['Outline', 'Underline', 'None'],
        (v) => _set('borderStyle', v)));
      items.add(_BoolRow('Filled', _bln('filled', true), (v) => _set('filled', v)));
      items.add(_BoolRow('Obscure Text', _bln('obscureText'), (v) => _set('obscureText', v)));
      items.add(_BoolRow('Enabled', _bln('enabled', true), (v) => _set('enabled', v)));
      items.add(_NumRow('Max Lines', _num('maxLines', 1), 1, 10, (v) => _set('maxLines', v)));
    }

    // ── Dropdown ──
    if (type == 'DropdownButton') {
      items.add(_Section('Dropdown'));
      items.add(_TField('Items (comma-separated)', _str('items', 'Option 1,Option 2,Option 3'),
        (v) => _set('items', v)));
      items.add(_TField('Selected Value', _str('value', 'Option 1'), (v) => _set('value', v)));
    }

    // ── Segmented Button ──
    if (type == 'SegmentedButton') {
      items.add(_Section('Segments'));
      items.add(_TField('Segment 1', _str('seg1', 'Day'), (v) => _set('seg1', v)));
      items.add(_TField('Segment 2', _str('seg2', 'Week'), (v) => _set('seg2', v)));
      items.add(_TField('Segment 3', _str('seg3', 'Month'), (v) => _set('seg3', v)));
      items.add(_NumRow('Selected', _num('selected'), 0, 2, (v) => _set('selected', v)));
      items.add(_BoolRow('Multi-select', _bln('multiSelect'), (v) => _set('multiSelect', v)));
    }

    // ── Alert Dialog ──
    if (type == 'AlertDialog') {
      items.add(_Section('Dialog'));
      items.add(_TField('Content', _str('content'), (v) => _set('content', v), maxLines: 3));
    }

    // ── Snackbar ──
    if (type == 'SnackBar') {
      items.add(_Section('Snackbar'));
      items.add(_DropRow('Behavior', _str('behavior', 'floating'),
        const ['floating', 'fixed'], const ['Floating', 'Fixed'],
        (v) => _set('behavior', v)));
      items.add(_BoolRow('Has Action', _bln('hasAction', true), (v) => _set('hasAction', v)));
      items.add(_NumRow('Duration (sec)', _num('duration', 4), 1, 10, (v) => _set('duration', v)));
    }

    // ── BottomSheet ──
    if (type == 'BottomSheet') {
      items.add(_Section('Bottom Sheet'));
      items.add(_BoolRow('Show Handle', _bln('showHandle', true), (v) => _set('showHandle', v)));
      items.add(_NumRow('Item Count', _num('itemCount', 3), 1, 8, (v) => _set('itemCount', v)));
    }

    // ── DataTable ──
    if (type == 'DataTable') {
      items.add(_Section('Data Table'));
      items.add(_TField('Columns (comma-sep)', _str('columns', 'Name,Age,City'), (v) => _set('columns', v)));
      items.add(_NumRow('Row Count', int.tryParse(_str('rows', '3')) ?? 3, 1, 10,
        (v) => _set('rows', v.toString())));
    }

    // ── Stepper ──
    if (type == 'StepperWidget') {
      items.add(_Section('Stepper'));
      items.add(_NumRow('Step Count', _num('steps', 3), 2, 6, (v) => _set('steps', v)));
      items.add(_NumRow('Current Step', _num('currentStep', 1), 0, _num('steps', 3) - 1,
        (v) => _set('currentStep', v)));
      items.add(_DropRow('Type', _str('type', 'vertical'),
        const ['vertical', 'horizontal'], const ['Vertical', 'Horizontal'],
        (v) => _set('type', v)));
    }

    // ── PageView ──
    if (type == 'PageView') {
      items.add(_Section('Pages'));
      items.add(_NumRow('Page Count', _num('pageCount', 3), 1, 10, (v) => _set('pageCount', v)));
      items.add(_BoolRow('Page Indicator', _bln('indicator', true), (v) => _set('indicator', v)));
    }

    // ── GridView ──
    if (type == 'GridView') {
      items.add(_Section('Grid'));
      items.add(_NumRow('Columns', _num('crossAxisCount', 2), 1, 6, (v) => _set('crossAxisCount', v)));
      items.add(_SliderRow('H Spacing', _dbl('crossAxisSpacing', 8), 0, 32, (v) => _set('crossAxisSpacing', v)));
      items.add(_SliderRow('V Spacing', _dbl('mainAxisSpacing', 8), 0, 32, (v) => _set('mainAxisSpacing', v)));
      items.add(_SliderRow('Aspect Ratio', _dbl('childAspectRatio', 1), 0.3, 3.0, (v) => _set('childAspectRatio', v)));
    }

    // ── ListView ──
    if (type == 'ListView') {
      items.add(_Section('List'));
      items.add(_NumRow('Item Count', _num('itemCount', 5), 1, 20, (v) => _set('itemCount', v)));
      items.add(_BoolRow('Separators', _bln('separators', true), (v) => _set('separators', v)));
      items.add(_DropRow('Scroll Dir', _str('scrollDirection', 'vertical'),
        const ['vertical', 'horizontal'], const ['Vertical', 'Horizontal'],
        (v) => _set('scrollDirection', v)));
    }

    // ── ListTile ──
    if (type == 'ListTile') {
      items.add(_Section('List Tile'));
      items.add(_BoolRow('Dense', _bln('dense'), (v) => _set('dense', v)));
      items.add(_BoolRow('Selected', _bln('selected'), (v) => _set('selected', v)));
      items.add(_BoolRow('Enabled', _bln('enabled', true), (v) => _set('enabled', v)));
      items.add(_BoolRow('Three Line', _bln('isThreeLine'), (v) => _set('isThreeLine', v)));
      items.add(_SliderRow('Min Height', _dbl('minHeight', 56), 40, 120, (v) => _set('minHeight', v)));
    }

    // ── Divider ──
    if (type == 'Divider') {
      items.add(_Section('Divider'));
      items.add(_SliderRow('Thickness', _dbl('thickness', 1), 0.5, 16, (v) => _set('thickness', v)));
      items.add(_SliderRow('Indent', _dbl('indent'), 0, 80, (v) => _set('indent', v)));
      items.add(_SliderRow('End Indent', _dbl('endIndent'), 0, 80, (v) => _set('endIndent', v)));
      items.add(_BoolRow('Vertical', _bln('vertical'), (v) => _set('vertical', v)));
    }

    // ── Custom Widget ──
    if (type == 'CustomWidget') {
      items.add(_Section('Custom Widget'));
      items.add(_TField('Widget Name', _str('name', 'MyWidget'), (v) => _set('name', v)));
      items.add(_BoolRow('Show Icon', _bln('showIcon'), (v) => _set('showIcon', v)));
      if (_bln('showIcon')) items.add(_SliderRow('Icon Size', _dbl('iconSize', 32), 12, 64, (v) => _set('iconSize', v)));
    }

    // ── Badge ──
    if (type == 'Badge') {
      items.add(_Section('Badge'));
      items.add(_TField('Badge Text', _str('label', '9+'), (v) => _set('label', v)));
      items.add(_TField('Child Text', _str('childText', 'Inbox'), (v) => _set('childText', v)));
      items.add(_SliderRow('Font Size', _dbl('fontSize', 12), 8, 20, (v) => _set('fontSize', v)));
    }

    // ── Tooltip ──
    if (type == 'Tooltip') {
      items.add(_Section('Tooltip'));
      items.add(_TField('Child Text', _str('childText', 'Hover me'), (v) => _set('childText', v)));
      items.add(_BoolRow('Prefer Below', _bln('preferBelow', true), (v) => _set('preferBelow', v)));
    }

    // ── Animated ──
    if (type == 'AnimatedContainer' || type == 'AnimatedOpacity') {
      items.add(_Section('Animation'));
      items.add(_SliderRow('Duration (ms)', _dbl('duration', 500), 100, 2000, (v) => _set('duration', v)));
      if (type == 'AnimatedOpacity') {
        items.add(_SliderRow('Opacity', _dbl('opacity', 0.5), 0, 1, (v) => _set('opacity', v)));
      }
    }

    // ── Expansion Tile ──
    if (type == 'ExpansionTile') {
      items.add(_Section('Expansion'));
      items.add(_BoolRow('Initially Expanded', _bln('expanded'), (v) => _set('expanded', v)));
      items.add(_NumRow('Child Count', _num('childCount', 3), 1, 8, (v) => _set('childCount', v)));
      items.add(_TField('Child Label', _str('childLabel', 'Item'), (v) => _set('childLabel', v)));
    }

    // ── Breadcrumb ──
    if (type == 'Breadcrumb') {
      items.add(_Section('Breadcrumb'));
      items.add(_TField('Items (> separated)', _str('items', 'Home > Products > Detail'), (v) => _set('items', v)));
    }

    if (items.isEmpty) items.add(const _EmptyState('No specific properties'));
    items.add(const SizedBox(height: 24));
    return items;
  }

  bool _hasKey(String key) => widget_.props.containsKey(key);
}

// ══════════════════════════════════════════════
// LAYOUT TAB (position, size, z-index)
// ══════════════════════════════════════════════
class _LayoutTab extends StatelessWidget {
  final WidgetProperty widget_;
  final EditorNotifier notifier;
  const _LayoutTab({required this.widget_, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: [
        _Section('Dimensions'),
        Row(children: [
          Expanded(child: _NumFieldWidget(label: 'Width', value: widget_.width,
            onChanged: (v) => notifier.resizeWidget(widget_.id, v, widget_.height))),
          const SizedBox(width: 10),
          Expanded(child: _NumFieldWidget(label: 'Height', value: widget_.height,
            onChanged: (v) => notifier.resizeWidget(widget_.id, widget_.width, v))),
        ]),
        _Section('Position'),
        Row(children: [
          Expanded(child: _NumFieldWidget(label: 'X', value: widget_.x,
            onChanged: (v) => notifier.moveWidget(widget_.id, v - widget_.x, 0))),
          const SizedBox(width: 10),
          Expanded(child: _NumFieldWidget(label: 'Y', value: widget_.y,
            onChanged: (v) => notifier.moveWidget(widget_.id, 0, v - widget_.y))),
        ]),
        _Section('Layer'),
        _SliderRow('Z-Index', widget_.zIndex.toDouble(), 0, 50,
          (v) => notifier.updateWidgetProp(widget_.id, 'zIndex', v.round()),
          showValue: true),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.flip_to_front_rounded, size: 16),
            label: const Text('Front'),
            onPressed: () => notifier.bringToFront(widget_.id),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.flip_to_back_rounded, size: 16),
            label: const Text('Back'),
            onPressed: () => notifier.updateWidgetProp(widget_.id, 'zIndex', 0),
          )),
        ]),
        _Section('Quick Resize'),
        Wrap(spacing: 6, runSpacing: 6, children: [
          _QuickSizeBtn('Phone Full', 390, 844, widget_, notifier),
          _QuickSizeBtn('Card', 320, 180, widget_, notifier),
          _QuickSizeBtn('Banner', 340, 80, widget_, notifier),
          _QuickSizeBtn('Button', 160, 48, widget_, notifier),
          _QuickSizeBtn('FAB', 56, 56, widget_, notifier),
          _QuickSizeBtn('Icon', 48, 48, widget_, notifier),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _QuickSizeBtn extends StatelessWidget {
  final String label;
  final double w, h;
  final WidgetProperty widget_;
  final EditorNotifier notifier;
  const _QuickSizeBtn(this.label, this.w, this.h, this.widget_, this.notifier);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('$label\n${w.round()}×${h.round()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
      onPressed: () => notifier.resizeWidget(widget_.id, w, h),
    );
  }
}

// ══════════════════════════════════════════════
// STYLE TAB (colors, shape, effects)
// ══════════════════════════════════════════════
class _StyleTab extends StatelessWidget {
  final BuildContext context;
  final WidgetProperty widget_;
  final EditorNotifier notifier;
  const _StyleTab({required this.context, required this.widget_, required this.notifier});

  void _set(String key, dynamic val) => notifier.updateWidgetProp(widget_.id, key, val);
  dynamic _get(String key, [dynamic fb]) => widget_.props[key] ?? fb;
  Color _col(String key, [int fb = 0xFF6750A4]) => Color((_get(key, fb)) as int);
  double _dbl(String key, [double fb = 0]) => ((_get(key, fb)) as num).toDouble();
  bool _bln(String key, [bool fb = false]) => (_get(key, fb) as bool?) ?? fb;

  @override
  Widget build(BuildContext context_) {
    final p = widget_.props;
    final items = <Widget>[];

    // ── Colors ──
    items.add(_Section('Colors'));
    _colorKeys().forEach((key, label) {
      if (p.containsKey(key)) {
        items.add(_ColorRow(context: context, label: label,
          value: _col(key), onChanged: (c) => _set(key, c.value)));
      }
    });

    // ── Shape ──
    if (p.containsKey('borderRadius')) {
      items.add(_Section('Shape'));
      items.add(_SliderRow('Border Radius', _dbl('borderRadius'), 0, 100, (v) => _set('borderRadius', v), showValue: true));
      if (p.containsKey('topLeftRadius')) {
        items.add(Row(children: [
          Expanded(child: _SliderRow('↖ TL', _dbl('topLeftRadius', -1) < 0 ? _dbl('borderRadius') : _dbl('topLeftRadius'), 0, 100, (v) => _set('topLeftRadius', v))),
          const SizedBox(width: 4),
          Expanded(child: _SliderRow('↗ TR', _dbl('topRightRadius', -1) < 0 ? _dbl('borderRadius') : _dbl('topRightRadius'), 0, 100, (v) => _set('topRightRadius', v))),
        ]));
        items.add(Row(children: [
          Expanded(child: _SliderRow('↙ BL', _dbl('bottomLeftRadius', -1) < 0 ? _dbl('borderRadius') : _dbl('bottomLeftRadius'), 0, 100, (v) => _set('bottomLeftRadius', v))),
          const SizedBox(width: 4),
          Expanded(child: _SliderRow('↘ BR', _dbl('bottomRightRadius', -1) < 0 ? _dbl('borderRadius') : _dbl('bottomRightRadius'), 0, 100, (v) => _set('bottomRightRadius', v))),
        ]));
      }
    }

    // ── Elevation ──
    if (p.containsKey('elevation')) {
      items.add(_SliderRow('Elevation', _dbl('elevation'), 0, 24, (v) => _set('elevation', v), showValue: true));
    }

    // ── Opacity ──
    if (p.containsKey('opacity')) {
      items.add(_Section('Opacity'));
      items.add(_SliderRow('Opacity', _dbl('opacity', 1.0), 0, 1, (v) => _set('opacity', v), showValue: true));
    }

    // ── Padding ──
    if (p.containsKey('padding')) {
      items.add(_Section('Padding'));
      items.add(_SliderRow('All', _dbl('padding'), 0, 64, (v) => _set('padding', v), showValue: true));
      if (p.containsKey('paddingLeft')) {
        items.add(Row(children: [
          Expanded(child: _SliderRow('L', _dbl('paddingLeft', -1) < 0 ? _dbl('padding') : _dbl('paddingLeft'), 0, 64, (v) => _set('paddingLeft', v))),
          const SizedBox(width: 4),
          Expanded(child: _SliderRow('R', _dbl('paddingRight', -1) < 0 ? _dbl('padding') : _dbl('paddingRight'), 0, 64, (v) => _set('paddingRight', v))),
        ]));
        items.add(Row(children: [
          Expanded(child: _SliderRow('T', _dbl('paddingTop', -1) < 0 ? _dbl('padding') : _dbl('paddingTop'), 0, 64, (v) => _set('paddingTop', v))),
          const SizedBox(width: 4),
          Expanded(child: _SliderRow('B', _dbl('paddingBottom', -1) < 0 ? _dbl('padding') : _dbl('paddingBottom'), 0, 64, (v) => _set('paddingBottom', v))),
        ]));
      }
    }

    // ── Border ──
    if (p.containsKey('hasBorder')) {
      items.add(_Section('Border'));
      items.add(_BoolRow2('Show Border', _bln('hasBorder'), (v) => _set('hasBorder', v)));
      if (_bln('hasBorder') && p.containsKey('borderWidth')) {
        items.add(_SliderRow('Width', _dbl('borderWidth', 1), 0.5, 12, (v) => _set('borderWidth', v), showValue: true));
        if (p.containsKey('borderStyle')) {
          items.add(_DropRow('Style', p['borderStyle'] as String? ?? 'solid',
            const ['solid', 'dashed'], const ['Solid', 'Dashed'], (v) => _set('borderStyle', v)));
        }
      }
    }

    // ── Gradient ──
    if (p.containsKey('hasGradient')) {
      items.add(_Section('Gradient'));
      items.add(_BoolRow2('Enable Gradient', _bln('hasGradient'), (v) => _set('hasGradient', v)));
      if (_bln('hasGradient')) {
        items.add(_ColorRow(context: context, label: 'Start Color',
          value: _col('gradientStart', 0xFF6750A4), onChanged: (c) => _set('gradientStart', c.value)));
        items.add(_ColorRow(context: context, label: 'End Color',
          value: _col('gradientEnd', 0xFF03DAC6), onChanged: (c) => _set('gradientEnd', c.value)));
        items.add(_DropRow('Direction', p['gradientAngle'] as String? ?? 'vertical',
          const ['vertical', 'horizontal', 'diagonal'],
          const ['Vertical', 'Horizontal', 'Diagonal'],
          (v) => _set('gradientAngle', v)));
      }
    }

    // ── Shadow ──
    if (p.containsKey('hasShadow')) {
      items.add(_Section('Shadow'));
      items.add(_BoolRow2('Enable Shadow', _bln('hasShadow'), (v) => _set('hasShadow', v)));
      if (_bln('hasShadow')) {
        items.add(_ColorRow(context: context, label: 'Shadow Color',
          value: _col('shadowColor', 0x40000000), onChanged: (c) => _set('shadowColor', c.value)));
        items.add(_SliderRow('Blur', _dbl('shadowBlur', 8), 0, 40, (v) => _set('shadowBlur', v), showValue: true));
        items.add(_SliderRow('Offset X', _dbl('shadowX'), -20, 20, (v) => _set('shadowX', v), showValue: true));
        items.add(_SliderRow('Offset Y', _dbl('shadowY', 4), -20, 20, (v) => _set('shadowY', v), showValue: true));
      }
    }

    if (items.isEmpty) items.add(const _EmptyState('No style properties'));
    items.add(const SizedBox(height: 24));
    return ListView(padding: const EdgeInsets.fromLTRB(14, 8, 14, 0), children: items);
  }

  Map<String, String> _colorKeys() => const {
    'color': 'Primary Color', 'textColor': 'Text Color',
    'backgroundColor': 'Background', 'activeColor': 'Active Color',
    'inactiveColor': 'Inactive Color', 'thumbColor': 'Thumb Color',
    'labelColor': 'Label Color', 'unselectedColor': 'Unselected',
    'indicatorColor': 'Indicator', 'selectedColor': 'Selected',
    'iconColor': 'Icon Color', 'fillColor': 'Fill Color',
    'actionColor': 'Action Color', 'titleColor': 'Title Color',
    'contentColor': 'Content Color', 'buttonColor': 'Button Color',
    'headerColor': 'Header Color', 'handleColor': 'Handle Color',
    'dividerColor': 'Divider Color', 'separatorColor': 'Separator',
    'shadowColor': 'Shadow Color', 'borderColor': 'Border Color',
    'checkColor': 'Check Color', 'subtitleColor': 'Subtitle Color',
  };
}

// ══════════════════════════════════════════════
// SHARED HELPER WIDGETS
// ══════════════════════════════════════════════

class _Section extends StatelessWidget {
  final String label;
  const _Section(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 5),
      child: Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label.toUpperCase(), style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary, letterSpacing: 1.0)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String msg;
  const _EmptyState(this.msg);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(child: Text(msg, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13))),
  );
}

Widget _SliderRow(String label, double value, double min, double max,
    void Function(double) onChanged, {bool showValue = false}) {
  return _SliderRowWidget(label: label, value: value, min: min, max: max,
      onChanged: onChanged, showValue: showValue);
}

class _SliderRowWidget extends StatelessWidget {
  final String label;
  final double value, min, max;
  final void Function(double) onChanged;
  final bool showValue;
  const _SliderRowWidget({required this.label, required this.value,
    required this.min, required this.max, required this.onChanged, this.showValue = false});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 76, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(child: Slider(
        value: value.clamp(min, max), min: min, max: max,
        onChanged: onChanged,
      )),
      if (showValue) SizedBox(width: 38, child: Text(
        value < 1.5 ? value.toStringAsFixed(2) : value.round().toString(),
        style: const TextStyle(fontSize: 11), textAlign: TextAlign.end)),
    ]);
  }
}

Widget _SegRow(String label, String selected, List<String> options, List<String> labels,
    void Function(String) onChanged) {
  return _SegRowWidget(label: label, selected: selected, options: options,
      labels: labels, onChanged: onChanged);
}

class _SegRowWidget extends StatelessWidget {
  final String label, selected;
  final List<String> options, labels;
  final void Function(String) onChanged;
  const _SegRowWidget({required this.label, required this.selected,
    required this.options, required this.labels, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 76, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(child: SegmentedButton<String>(
          segments: List.generate(options.length, (i) =>
            ButtonSegment(value: options[i], label: Text(labels[i], style: const TextStyle(fontSize: 11)))),
          selected: {selected},
          onSelectionChanged: (s) => onChanged(s.first),
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        )),
      ]),
    );
  }
}

Widget _DropRow(String label, String value, List<String> options, List<String> labels,
    void Function(String) onChanged) {
  return _DropRowWidget(label: label, value: value, options: options,
      labels: labels, onChanged: onChanged);
}

class _DropRowWidget extends StatelessWidget {
  final String label, value;
  final List<String> options, labels;
  final void Function(String) onChanged;
  const _DropRowWidget({required this.label, required this.value,
    required this.options, required this.labels, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final safeVal = options.contains(value) ? value : options.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 76, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(child: DropdownButtonFormField<String>(
          value: safeVal,
          isDense: true,
          decoration: const InputDecoration(
            isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
          items: List.generate(options.length, (i) =>
            DropdownMenuItem(value: options[i], child: Text(labels[i], style: const TextStyle(fontSize: 13)))),
          onChanged: (v) { if (v != null) onChanged(v); },
        )),
      ]),
    );
  }
}

class _TField extends StatefulWidget {
  final String label, value;
  final void Function(String) onChanged;
  final int maxLines;
  const _TField(this.label, this.value, this.onChanged, {this.maxLines = 1});
  @override
  State<_TField> createState() => _TFieldState();
}
class _TFieldState extends State<_TField> {
  late TextEditingController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = TextEditingController(text: widget.value); }
  @override
  void didUpdateWidget(_TField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _ctrl.text != widget.value) _ctrl.text = widget.value;
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: _ctrl, maxLines: widget.maxLines,
      decoration: InputDecoration(labelText: widget.label, isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
      onChanged: widget.onChanged,
    ),
  );
}

class _NumFieldWidget extends StatefulWidget {
  final String label;
  final double value;
  final void Function(double) onChanged;
  const _NumFieldWidget({required this.label, required this.value, required this.onChanged});
  @override
  State<_NumFieldWidget> createState() => _NumFieldWidgetState();
}
class _NumFieldWidgetState extends State<_NumFieldWidget> {
  late TextEditingController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = TextEditingController(text: widget.value.round().toString()); }
  @override
  void didUpdateWidget(_NumFieldWidget old) {
    super.didUpdateWidget(old);
    final txt = widget.value.round().toString();
    if (_ctrl.text != txt) _ctrl.text = txt;
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => TextField(
    controller: _ctrl,
    decoration: InputDecoration(labelText: widget.label, isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
    keyboardType: TextInputType.number,
    onSubmitted: (v) { final d = double.tryParse(v); if (d != null) widget.onChanged(d); },
  );
}

Widget _BoolRow(String label, bool value, void Function(bool) onChanged) =>
    _BoolRowWidget(label: label, value: value, onChanged: onChanged);

Widget _BoolRow2(String label, bool value, void Function(bool) onChanged) =>
    _BoolRowWidget(label: label, value: value, onChanged: onChanged);

class _BoolRowWidget extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _BoolRowWidget({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SwitchListTile(
    title: Text(label, style: const TextStyle(fontSize: 13)),
    value: value, onChanged: onChanged, dense: true, contentPadding: EdgeInsets.zero,
  );
}

Widget _NumRow(String label, int value, int min, int max, void Function(int) onChanged, {String hint = ''}) =>
    _NumRowWidget(label: label, value: value, min: min, max: max, onChanged: onChanged, hint: hint);

class _NumRowWidget extends StatelessWidget {
  final String label, hint;
  final int value, min, max;
  final void Function(int) onChanged;
  const _NumRowWidget({required this.label, required this.value, required this.min,
    required this.max, required this.onChanged, this.hint = ''});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 100, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        if (hint.isNotEmpty) Text(hint, style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ])),
      Expanded(child: Slider(value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
        min: min.toDouble(), max: max.toDouble(), divisions: max - min,
        label: value.toString(), onChanged: (v) => onChanged(v.round()))),
      SizedBox(width: 30, child: Text(value.toString(), style: const TextStyle(fontSize: 12), textAlign: TextAlign.end)),
    ]);
  }
}

class _ColorRow extends StatelessWidget {
  final BuildContext context;
  final String label;
  final Color value;
  final void Function(Color) onChanged;
  const _ColorRow({required this.context, required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext _) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12))),
      GestureDetector(
        onTap: () => _pick(),
        child: Container(width: 32, height: 32,
          decoration: BoxDecoration(color: value, borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black26))),
      ),
      const SizedBox(width: 8),
      Expanded(child: GestureDetector(
        onTap: () => _pick(),
        child: Text('#${value.value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
          style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
      )),
    ]),
  );
  void _pick() {
    Color temp = value;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Pick $label', style: const TextStyle(fontSize: 16)),
      content: SingleChildScrollView(child: ColorPicker(
        pickerColor: value, onColorChanged: (c) => temp = c,
        enableAlpha: true, labelTypes: const [],
      )),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () { onChanged(temp); Navigator.pop(ctx); }, child: const Text('Apply')),
      ],
    ));
  }
}
