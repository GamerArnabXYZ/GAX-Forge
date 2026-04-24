// lib/screens/widgets/canvas/canvas_widget_renderer.dart
// GAX Forge - Renders all widget types on canvas

import 'package:flutter/material.dart';
import '../../../models/app_models.dart';

class CanvasWidgetRenderer extends StatelessWidget {
  final WidgetProperty widgetProp;

  const CanvasWidgetRenderer({super.key, required this.widgetProp});

  @override
  Widget build(BuildContext context) {
    final p = widgetProp.props;

    Color color(String key, [int fallback = 0xFF6750A4]) {
      return Color((p[key] as int?) ?? fallback);
    }

    double dbl(String key, [double fallback = 0]) {
      return (p[key] as num?)?.toDouble() ?? fallback;
    }

    String str(String key, [String fallback = '']) {
      return (p[key] as String?) ?? fallback;
    }

    bool bln(String key, [bool fallback = false]) {
      return (p[key] as bool?) ?? fallback;
    }

    switch (widgetProp.type) {
      // ── Container ─────────────────────────────
      case 'Container':
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widgetProp.width,
          height: widgetProp.height,
          padding: EdgeInsets.all(dbl('padding', 8)),
          margin: EdgeInsets.all(dbl('margin', 0)),
          decoration: BoxDecoration(
            color: color('color').withValues(alpha: dbl('opacity', 1.0)),
            borderRadius: BorderRadius.circular(dbl('borderRadius', 0)),
            border: bln('hasBorder')
                ? Border.all(
                    color: color('borderColor', 0xFF000000),
                    width: dbl('borderWidth', 1))
                : null,
          ),
        );

      // ── Text ──────────────────────────────────
      case 'Text':
        return SizedBox(
          width: widgetProp.width,
          height: widgetProp.height,
          child: Align(
            alignment: _textAlign(str('textAlign')),
            child: Text(
              str('text', 'Text Widget'),
              style: TextStyle(
                fontSize: dbl('fontSize', 16),
                color: color('color', 0xFF000000),
                fontWeight: str('fontWeight') == 'bold'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        );

      // ── ElevatedButton ─────────────────────────
      case 'ElevatedButton':
        return SizedBox(
          width: widgetProp.width,
          height: widgetProp.height,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color('color'),
              foregroundColor: color('textColor', 0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dbl('borderRadius', 12)),
              ),
            ),
            onPressed: () {},
            child: Text(str('text', 'Button'),
                style: TextStyle(fontSize: dbl('fontSize', 14))),
          ),
        );

      // ── OutlinedButton ─────────────────────────
      case 'OutlinedButton':
        return SizedBox(
          width: widgetProp.width,
          height: widgetProp.height,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: color('color'),
              side: BorderSide(color: color('color')),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dbl('borderRadius', 12)),
              ),
            ),
            onPressed: () {},
            child: Text(str('text', 'Outlined'),
                style: TextStyle(fontSize: dbl('fontSize', 14))),
          ),
        );

      // ── TextButton ─────────────────────────────
      case 'TextButton':
        return SizedBox(
          width: widgetProp.width,
          height: widgetProp.height,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: color('color')),
            onPressed: () {},
            child: Text(str('text', 'Text Button'),
                style: TextStyle(fontSize: dbl('fontSize', 14))),
          ),
        );

      // ── FilledButton ───────────────────────────
      case 'FilledButton':
        return SizedBox(
          width: widgetProp.width,
          height: widgetProp.height,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color('color')),
            onPressed: () {},
            child: Text(str('text', 'Filled')),
          ),
        );

      // ── IconButton ─────────────────────────────
      case 'IconButton':
        return SizedBox(
          width: widgetProp.width,
          height: widgetProp.height,
          child: Center(
            child: IconButton(
              icon: Icon(
                _safeIcon(p['iconCode'] as int?, Icons.star_rounded),
                color: color('color'),
              ),
              onPressed: () {},
            ),
          ),
        );

      // ── FloatingActionButton ───────────────────
      case 'FloatingActionButton':
        return Center(
          child: bln('mini')
              ? FloatingActionButton.small(
                  backgroundColor: color('color'),
                  onPressed: () {},
                  child: Icon(
                    _safeIcon(p['iconCode'] as int?, Icons.add_rounded),
                    color: color('iconColor', 0xFFFFFFFF),
                  ),
                )
              : FloatingActionButton(
                  backgroundColor: color('color'),
                  onPressed: () {},
                  child: Icon(
                    _safeIcon(p['iconCode'] as int?, Icons.add_rounded),
                    color: color('iconColor', 0xFFFFFFFF),
                  ),
                ),
        );

      // ── Card ───────────────────────────────────
      case 'Card':
        return Card(
          color: color('color', 0xFFFFFFFF),
          elevation: dbl('elevation', 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dbl('borderRadius', 12)),
          ),
          child: SizedBox(
            width: widgetProp.width,
            height: widgetProp.height,
          ),
        );

      // ── TextField ──────────────────────────────
      case 'TextField':
        return SizedBox(
          width: widgetProp.width,
          height: widgetProp.height,
          child: TextField(
            decoration: InputDecoration(
              hintText: str('hintText', 'Enter text...'),
              labelText: str('labelText', 'Label'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(dbl('borderRadius', 8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(dbl('borderRadius', 8)),
                borderSide: BorderSide(color: color('color')),
              ),
            ),
            enabled: false,
          ),
        );

      // ── SearchBar ──────────────────────────────
      case 'SearchBar':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          decoration: BoxDecoration(
            color: color('color', 0xFFF3EFF4),
            borderRadius: BorderRadius.circular(dbl('borderRadius', 28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 20),
              const SizedBox(width: 8),
              Text(str('hintText', 'Search...'),
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        );

      // ── Icon ───────────────────────────────────
      case 'Icon':
        return SizedBox(
          width: widgetProp.width,
          height: widgetProp.height,
          child: Center(
            child: Icon(
              _safeIcon(p['iconCode'] as int?, Icons.star_rounded),
              color: color('color'),
              size: dbl('size', 32),
            ),
          ),
        );

      // ── CircleAvatar ───────────────────────────
      case 'CircleAvatar':
        return Center(
          child: CircleAvatar(
            backgroundColor: color('color'),
            radius: dbl('radius', 30),
            child: Text(
              str('text', 'A'),
              style: TextStyle(
                color: color('textColor', 0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: dbl('radius', 30) * 0.7,
              ),
            ),
          ),
        );

      // ── Switch ─────────────────────────────────
      case 'Switch':
        return Center(
          child: Switch(
            value: bln('value', true),
            activeColor: color('activeColor'),
            onChanged: (_) {},
          ),
        );

      // ── Checkbox ───────────────────────────────
      case 'Checkbox':
        return Center(
          child: Checkbox(
            value: bln('value', true),
            activeColor: color('activeColor'),
            onChanged: (_) {},
          ),
        );

      // ── Slider ─────────────────────────────────
      case 'Slider':
        return Center(
          child: Slider(
            value: dbl('value', 0.5),
            min: dbl('min', 0),
            max: dbl('max', 1),
            activeColor: color('activeColor'),
            onChanged: (_) {},
          ),
        );

      // ── LinearProgressIndicator ────────────────
      case 'LinearProgressIndicator':
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: dbl('value', 0.6),
              color: color('color'),
              backgroundColor: color('backgroundColor', 0xFFE8DEF8),
              minHeight: 8,
            ),
          ),
        );

      // ── CircularProgressIndicator ──────────────
      case 'CircularProgressIndicator':
        return Center(
          child: CircularProgressIndicator(color: color('color')),
        );

      // ── Divider ────────────────────────────────
      case 'Divider':
        return Center(
          child: Divider(
            color: color('color', 0xFFCAC4D0),
            thickness: dbl('thickness', 1),
          ),
        );

      // ── Chip ───────────────────────────────────
      case 'Chip':
        return Center(
          child: Chip(
            label: Text(str('label', 'Chip'),
                style: TextStyle(color: color('textColor'))),
            backgroundColor: color('color', 0xFFE8DEF8),
          ),
        );

      // ── Badge ──────────────────────────────────
      case 'Badge':
        return Center(
          child: Badge(
            label: Text(str('label', '9+')),
            backgroundColor: color('color', 0xFFB3261E),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(str('childText', 'Badge')),
            ),
          ),
        );

      // ── ListTile ───────────────────────────────
      case 'ListTile':
        return Container(
          color: color('color', 0xFFFFFFFF),
          child: ListTile(
            leading: Icon(
              _safeIcon(p['leadingIcon'] as int?, Icons.star_rounded),
            ),
            title: Text(str('title', 'List Item'),
                style: TextStyle(color: color('textColor', 0xFF000000))),
            subtitle: Text(str('subtitle', 'Subtitle text')),
          ),
        );

      // ── AppBar ─────────────────────────────────
      case 'AppBar':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          color: color('color'),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.arrow_back_rounded,
                  color: color('textColor', 0xFFFFFFFF)),
              Expanded(
                child: Text(
                  str('title', 'App Bar'),
                  textAlign: bln('centerTitle', true)
                      ? TextAlign.center
                      : TextAlign.left,
                  style: TextStyle(
                    color: color('textColor', 0xFFFFFFFF),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.more_vert_rounded,
                  color: color('textColor', 0xFFFFFFFF)),
            ],
          ),
        );

      // ── BottomNavigationBar ────────────────────
      case 'BottomNavigationBar':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          decoration: BoxDecoration(
            color: color('color', 0xFFFFFFFF),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, str('item1', 'Home'),
                  color('selectedColor'), true),
              _navItem(Icons.search_rounded, str('item2', 'Search'),
                  color('selectedColor'), false),
              _navItem(Icons.person_rounded, str('item3', 'Profile'),
                  color('selectedColor'), false),
            ],
          ),
        );

      // ── TabBar ─────────────────────────────────
      case 'TabBar':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          color: color('color'),
          child: DefaultTabController(
            length: 3,
            child: TabBar(
              labelColor: color('indicatorColor', 0xFFFFFFFF),
              unselectedLabelColor:
                  color('indicatorColor', 0xFFFFFFFF).withValues(alpha: 0.6),
              indicatorColor: color('indicatorColor', 0xFFFFFFFF),
              tabs: [
                Tab(text: str('tab1', 'Tab 1')),
                Tab(text: str('tab2', 'Tab 2')),
                Tab(text: str('tab3', 'Tab 3')),
              ],
            ),
          ),
        );

      // ── SnackBar ───────────────────────────────
      case 'SnackBar':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          decoration: BoxDecoration(
            color: color('color', 0xFF323232),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  str('message', 'Snackbar message'),
                  style: TextStyle(color: color('textColor', 0xFFFFFFFF)),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('DISMISS',
                    style: TextStyle(color: Colors.amber.shade300)),
              ),
            ],
          ),
        );

      // ── AlertDialog ────────────────────────────
      case 'AlertDialog':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          decoration: BoxDecoration(
            color: color('color', 0xFFFFFFFF),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16)],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(str('title', 'Alert'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(str('content', 'Dialog content here'),
                  style: const TextStyle(fontSize: 14)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () {}, child: const Text('Cancel')),
                  FilledButton(onPressed: () {}, child: const Text('OK')),
                ],
              ),
            ],
          ),
        );

      // ── SizedBox ───────────────────────────────
      case 'SizedBox':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          decoration: BoxDecoration(
            border:
                Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
          ),
          child: const Center(
            child: Text('SizedBox',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ),
        );

      // ── Placeholder ────────────────────────────
      case 'Placeholder':
        return Placeholder(
          color: color('color', 0xFF6750A4),
          fallbackWidth: widgetProp.width,
          fallbackHeight: widgetProp.height,
        );

      // ── Column / Row / Stack / Layout Hints ────
      case 'Column':
      case 'Row':
      case 'Stack':
      case 'Wrap':
      case 'Expanded':
      case 'Padding':
      case 'GridView':
      case 'ListView':
      case 'SingleChildScrollView':
      case 'CustomScrollView':
      case 'PageView':
      case 'TabBarView':
        return _LayoutHint(type: widgetProp.type, size: Size(widgetProp.width, widgetProp.height));

      // ── NavigationDrawer ───────────────────────
      case 'NavigationDrawer':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          color: color('color', 0xFFFFFBFE),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(str('title', 'Menu'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: Text(str('item1', 'Home'))),
              ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: Text(str('item2', 'Settings'))),
              ListTile(
                  leading: const Icon(Icons.info_rounded),
                  title: Text(str('item3', 'About'))),
            ],
          ),
        );

      // ── Spacer ─────────────────────────────────
      case 'Spacer':
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                style: BorderStyle.solid),
            color: Colors.blue.withValues(alpha: 0.05),
          ),
          child: const Center(
            child: Text('Spacer',
                style: TextStyle(color: Colors.blue, fontSize: 11)),
          ),
        );

      default:
        return Container(
          width: widgetProp.width,
          height: widgetProp.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Center(
            child: Text(
              widgetProp.type,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
    }
  }

  Widget _navItem(IconData icon, String label, Color selectedColor, bool selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: selected ? selectedColor : Colors.grey),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: selected ? selectedColor : Colors.grey)),
      ],
    );
  }

  Alignment _textAlign(String align) {
    switch (align) {
      case 'center': return Alignment.center;
      case 'right': return Alignment.centerRight;
      default: return Alignment.centerLeft;
    }
  }
}

// ── Layout Hint Widget ──────────────────────────
class _LayoutHint extends StatelessWidget {
  final String type;
  final Size size;

  const _LayoutHint({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.07),
        border: Border.all(
            color: Colors.purple.withValues(alpha: 0.4), style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.view_quilt_rounded,
                color: Colors.purple.withValues(alpha: 0.6), size: 24),
            Text(type,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.purple.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Safe icon lookup — avoids runtime IconData (tree-shake safe) ────────────
IconData _safeIcon(int? codePoint, IconData fallback) {
  if (codePoint == null) return fallback;
  // Map common Material codepoints to const Icons
  const Map<int, IconData> _known = {
    0xe318: Icons.star_rounded,
    0xe145: Icons.add_rounded,
    0xe3af: Icons.image_rounded,
    0xe88a: Icons.home_rounded,
    0xe5c4: Icons.arrow_back_rounded,
    0xe5d2: Icons.arrow_forward_rounded,
    0xe876: Icons.check_rounded,
    0xe5cd: Icons.close_rounded,
    0xe3b4: Icons.info_rounded,
    0xe88e: Icons.settings_rounded,
    0xe7fd: Icons.person_rounded,
    0xe0be: Icons.email_rounded,
    0xe61c: Icons.phone_rounded,
    0xe0b0: Icons.lock_rounded,
    0xe0c8: Icons.visibility_rounded,
    0xe8b6: Icons.search_rounded,
    0xe148: Icons.edit_rounded,
    0xe872: Icons.delete_rounded,
    0xe5d3: Icons.menu_rounded,
    0xe5c3: Icons.more_vert_rounded,
    0xe5d4: Icons.notifications_rounded,
    0xe8b8: Icons.share_rounded,
    0xe2c7: Icons.favorite_rounded,
    0xe8dc: Icons.star,
    0xe838: Icons.bookmark_rounded,
    0xe0af: Icons.download_rounded,
    0xe2c4: Icons.upload_rounded,
    0xe1db: Icons.folder_rounded,
    0xe24d: Icons.attach_file_rounded,
    0xe1bc: Icons.camera_rounded,
    0xe04b: Icons.play_arrow_rounded,
    0xe047: Icons.pause_rounded,
    0xe5db: Icons.refresh_rounded,
    0xe8b5: Icons.send_rounded,
  };
  return _known[codePoint] ?? fallback;
}
